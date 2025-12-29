locals {
  resource_name_prefix = var.node_pool_name
  node_tags = {
    "ResourceType"      = "NodePool"
    "KubernetesVersion" = var.kubernetes_version
    "NodeShape"         = var.node_shape
    "OSType"            = "${var.os_name}-${var.os_version}"
    "AutomatedBy"       = "OpenTofu"
    "CreatedAt"         = timestamp()
  }
  all_tags             = merge(var.tags, local.node_tags)
  is_flex_shape        = contains(["VM.Standard.E3.Flex", "VM.Standard.E4.Flex", "VM.Standard.A1.Flex", "VM.Optimized3.Flex"], var.node_shape)
  is_arm_shape         = contains(["VM.Standard.A1.Flex"], var.node_shape)
  availability_domains = var.availability_domain != null ? [var.availability_domain] : [data.oci_identity_availability_domains.ads.availability_domains[0].name]
  nodes_per_ad         = ceil(var.node_pool_size / length(local.availability_domains))
  placement_configs = [
    for idx, ad in local.availability_domains : {
      availability_domain = ad
      subnet_id           = var.worker_subnet_id
      fault_domains       = null
    }
  ]
  formatted_os_name = replace(lower(var.os_name), " ", "-")
  initial_node_labels = concat(
    [
      { key = "name", value = var.node_pool_name },
      { key = "nodepool", value = var.node_pool_name },
      { key = "kubernetes.io/os", value = local.formatted_os_name },
      { key = "kubernetes.io/arch", value = local.is_arm_shape ? "arm64" : "amd64" }
    ],
    var.additional_node_labels
  )
}

data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_id
}

data "oci_core_images" "compatible_images" {
  compartment_id           = var.compartment_id
  operating_system         = var.os_name
  operating_system_version = var.os_version
  shape                    = var.node_shape
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

resource "oci_containerengine_node_pool" "node_pool" {
  compartment_id     = var.compartment_id
  cluster_id         = var.cluster_id
  kubernetes_version = var.kubernetes_version
  name               = local.resource_name_prefix
  node_shape         = var.node_shape

  node_source_details {
    image_id                = coalesce(var.node_image_id, try(data.oci_core_images.compatible_images.images[0].id, null))
    source_type             = "IMAGE"
    boot_volume_size_in_gbs = var.boot_volume_size_in_gbs
  }

  node_config_details {
    dynamic "placement_configs" {
      for_each = local.placement_configs
      content {
        availability_domain = placement_configs.value.availability_domain
        subnet_id           = placement_configs.value.subnet_id
        fault_domains       = placement_configs.value.fault_domains
      }
    }

    size                                = var.node_pool_size
    nsg_ids                             = var.network_security_group_ids
    kms_key_id                          = var.kms_key_id
    is_pv_encryption_in_transit_enabled = var.enable_pv_encryption_in_transit
  }

  dynamic "node_shape_config" {
    for_each = local.is_flex_shape ? [1] : []
    content {
      memory_in_gbs = var.memory_in_gbs
      ocpus         = var.ocpus
    }
  }

  dynamic "initial_node_labels" {
    for_each = local.initial_node_labels
    content {
      key   = initial_node_labels.value.key
      value = initial_node_labels.value.value
    }
  }

  dynamic "node_pool_cycling_details" {
    for_each = var.enable_node_recycling_policy ? [1] : []
    content {
      is_node_cycling_enabled = true
    }
  }

  ssh_public_key = var.ssh_public_key
  freeform_tags  = local.all_tags

  lifecycle {
    create_before_destroy = false
    ignore_changes = [
      defined_tags,
    ]
    precondition {
      condition     = !local.is_flex_shape || (var.memory_in_gbs != null && var.ocpus != null)
      error_message = "For flex shapes, both memory_in_gbs and ocpus must be specified."
    }
  }

  timeouts {
    create = "${var.timeouts.create}m"
    update = "${var.timeouts.update}m"
    delete = "${var.timeouts.delete}m"
  }
}

resource "null_resource" "deploy_cluster_autoscaler" {
  count = var.enable_autoscaling ? 1 : 0

  triggers = {
    node_pool_id = oci_containerengine_node_pool.node_pool.id
    min_nodes    = var.autoscaling_config.min_nodes
    max_nodes    = var.autoscaling_config.max_nodes
  }

  provisioner "local-exec" {
    command = <<-EOT
      echo "Configuring Cluster Autoscaler for node pool ${var.node_pool_name}..."
      KUBECONFIG=${var.kubeconfig_path}
      kubectl --kubeconfig $KUBECONFIG annotate nodepool.nodepool.k8s.io/${var.node_pool_name} \
        "nodepool.k8s.io/autoscaler-enabled=true" \
        "nodepool.k8s.io/autoscaler-min-nodes=${var.autoscaling_config.min_nodes}" \
        "nodepool.k8s.io/autoscaler-max-nodes=${var.autoscaling_config.max_nodes}" \
        --overwrite
      if ! kubectl --kubeconfig $KUBECONFIG get deployment -n kube-system cluster-autoscaler &>/dev/null; then
        echo "Installing cluster autoscaler via Helm..."
        helm --kubeconfig $KUBECONFIG repo add autoscaler https://kubernetes.github.io/autoscaler
        helm --kubeconfig $KUBECONFIG upgrade --install cluster-autoscaler autoscaler/cluster-autoscaler \
          --namespace kube-system \
          --set "autoDiscovery.clusterName=${var.cluster_id}" \
          --set "extraArgs.cloud-provider=oci" \
          --set "extraArgs.nodes=${var.autoscaling_config.min_nodes}:${var.autoscaling_config.max_nodes}:${var.node_pool_name}" \
          --set "extraArgs.max-node-provision-time=15m"
      else
        echo "Cluster autoscaler already installed, updating configuration..."
        kubectl --kubeconfig $KUBECONFIG patch deployment cluster-autoscaler -n kube-system \
          -p '{"spec":{"template":{"spec":{"$setElementOrder/containers":[{"name":"cluster-autoscaler"}],"containers":[{"name":"cluster-autoscaler","$setElementOrder/command":[0],"command":["./cluster-autoscaler"],"$setElementOrder/args":[0,1],"args":["--cloud-provider=oci","--nodes=${var.autoscaling_config.min_nodes}:${var.autoscaling_config.max_nodes}:${var.node_pool_name}"]}]}}}}'
      fi
      echo "Autoscaler configuration completed for node pool ${var.node_pool_name}"
    EOT
  }

  depends_on = [oci_containerengine_node_pool.node_pool]
}
