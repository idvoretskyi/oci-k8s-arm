data "external" "oci_config" {
  program = ["bash", "-c", "grep -E '^(tenancy|user)=' ~/.oci/config | sed 's/=/\":\"/' | sed 's/^/\"/' | sed 's/$/\",/' | tr -d '\n' | sed 's/,$//' | sed 's/^/{/' | sed 's/$/}/'"]
}

data "external" "current_user" {
  program = ["bash", "-c", "echo '{\"username\":\"'$(whoami)'\"}'"]
}

locals {
  tenancy_ocid       = data.external.oci_config.result.tenancy
  user_ocid          = data.external.oci_config.result.user
  compartment_id     = coalesce(var.compartment_ocid, local.tenancy_ocid)
  username           = var.username != null ? var.username : data.external.current_user.result.username
  cluster_name       = var.cluster_name != null ? var.cluster_name : "${local.username}-arm-oke-cluster"
  kubernetes_version = var.kubernetes_version != null ? var.kubernetes_version : data.oci_containerengine_cluster_option.options.kubernetes_versions[length(data.oci_containerengine_cluster_option.options.kubernetes_versions) - 1]
}

data "oci_containerengine_cluster_option" "options" {
  cluster_option_id = "all"
  compartment_id    = local.compartment_id
}

data "oci_identity_availability_domains" "ads" {
  compartment_id = local.compartment_id
}

data "oci_core_images" "arm_images" {
  compartment_id           = local.compartment_id
  operating_system         = "Oracle Linux"
  operating_system_version = "8"
  shape                    = "VM.Standard.A1.Flex"
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

resource "oci_core_vcn" "vcn" {
  compartment_id = local.compartment_id
  cidr_blocks    = ["10.0.0.0/16"]
  display_name   = "${local.cluster_name}-vcn"
  dns_label      = "armokecluster"
}

resource "oci_core_internet_gateway" "igw" {
  compartment_id = local.compartment_id
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "${local.cluster_name}-igw"
}

resource "oci_core_nat_gateway" "ngw" {
  compartment_id = local.compartment_id
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "${local.cluster_name}-ngw"
}

resource "oci_core_route_table" "public_rt" {
  compartment_id = local.compartment_id
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "${local.cluster_name}-public-rt"

  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.igw.id
  }
}

resource "oci_core_route_table" "private_rt" {
  compartment_id = local.compartment_id
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "${local.cluster_name}-private-rt"

  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_nat_gateway.ngw.id
  }
}

resource "oci_core_security_list" "oke_sl" {
  compartment_id = local.compartment_id
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "${local.cluster_name}-oke-sl"

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }

  ingress_security_rules {
    protocol = "all"
    source   = "10.0.0.0/16"
  }

  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"
    tcp_options {
      min = 6443
      max = 6443
    }
  }

  ingress_security_rules {
    protocol = "1"
    source   = "0.0.0.0/0"
    icmp_options {
      type = 3
      code = 4
    }
  }
}

resource "oci_core_network_security_group" "oke_cluster_nsg" {
  compartment_id = local.compartment_id
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "${local.cluster_name}-oke-cluster-nsg"
}

resource "oci_core_network_security_group_security_rule" "oke_cluster_nsg_ingress_k8s" {
  network_security_group_id = oci_core_network_security_group.oke_cluster_nsg.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"

  tcp_options {
    destination_port_range {
      min = 6443
      max = 6443
    }
  }
}

resource "oci_core_network_security_group_security_rule" "oke_cluster_nsg_egress_all" {
  network_security_group_id = oci_core_network_security_group.oke_cluster_nsg.id
  direction                 = "EGRESS"
  protocol                  = "all"
  destination               = "0.0.0.0/0"
  destination_type          = "CIDR_BLOCK"
}

resource "oci_core_subnet" "public_subnet" {
  compartment_id             = local.compartment_id
  vcn_id                     = oci_core_vcn.vcn.id
  cidr_block                 = "10.0.1.0/24"
  display_name               = "${local.cluster_name}-public"
  dns_label                  = "public"
  route_table_id             = oci_core_route_table.public_rt.id
  security_list_ids          = [oci_core_security_list.oke_sl.id]
  prohibit_public_ip_on_vnic = false
}

resource "oci_core_subnet" "private_subnet" {
  compartment_id             = local.compartment_id
  vcn_id                     = oci_core_vcn.vcn.id
  cidr_block                 = "10.0.2.0/24"
  display_name               = "${local.cluster_name}-private"
  dns_label                  = "private"
  route_table_id             = oci_core_route_table.private_rt.id
  security_list_ids          = [oci_core_security_list.oke_sl.id]
  prohibit_public_ip_on_vnic = true
}

resource "oci_containerengine_cluster" "arm_cluster" {
  compartment_id     = local.compartment_id
  kubernetes_version = local.kubernetes_version
  name               = local.cluster_name
  vcn_id             = oci_core_vcn.vcn.id

  endpoint_config {
    is_public_ip_enabled = true
    subnet_id            = oci_core_subnet.public_subnet.id
    nsg_ids              = [oci_core_network_security_group.oke_cluster_nsg.id]
  }

  options {
    service_lb_subnet_ids = [oci_core_subnet.public_subnet.id]

    add_ons {
      is_kubernetes_dashboard_enabled = false
      is_tiller_enabled               = false
    }

    admission_controller_options {
      is_pod_security_policy_enabled = false
    }

    kubernetes_network_config {
      pods_cidr     = "10.244.0.0/16"
      services_cidr = "10.96.0.0/16"
    }
  }
}

resource "oci_containerengine_node_pool" "arm_pool" {
  compartment_id     = local.compartment_id
  cluster_id         = oci_containerengine_cluster.arm_cluster.id
  kubernetes_version = local.kubernetes_version
  name               = "${local.cluster_name}-arm-pool"
  node_shape         = "VM.Standard.A1.Flex"

  node_config_details {
    size                                = var.node_count
    is_pv_encryption_in_transit_enabled = true

    placement_configs {
      availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
      subnet_id           = oci_core_subnet.private_subnet.id
    }

    node_pool_pod_network_option_details {
      cni_type          = "FLANNEL_OVERLAY"
      max_pods_per_node = 31
    }
  }

  node_shape_config {
    memory_in_gbs = var.node_memory_gb
    ocpus         = var.node_ocpus
  }

  node_source_details {
    source_type             = "IMAGE"
    image_id                = data.oci_core_images.arm_images.images[0].id
    boot_volume_size_in_gbs = 50
  }

  initial_node_labels {
    key   = "oci.oraclecloud.com/encrypt-in-transit"
    value = "true"
  }

  initial_node_labels {
    key   = "kubernetes.io/arch"
    value = "arm64"
  }

  initial_node_labels {
    key   = "node.kubernetes.io/instance-type"
    value = "arm64"
  }
}

resource "null_resource" "metrics_server" {
  triggers = {
    cluster_endpoint = oci_containerengine_cluster.arm_cluster.endpoints[0].public_endpoint
    cluster_id       = oci_containerengine_cluster.arm_cluster.id
  }

  provisioner "local-exec" {
    command = <<-EOT
      sleep 30
      kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
      kubectl wait --for=condition=ready pod -l k8s-app=metrics-server -n kube-system --timeout=120s || true
    EOT

    environment = {
      KUBECONFIG = pathexpand("~/.kube/config")
    }
  }

  provisioner "local-exec" {
    when    = destroy
    command = "kubectl delete -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml --ignore-not-found=true || true"

    environment = {
      KUBECONFIG = pathexpand("~/.kube/config")
    }
  }

  depends_on = [oci_containerengine_node_pool.arm_pool]
}

module "monitoring" {
  source             = "../modules/monitoring"
  cluster_id         = oci_containerengine_cluster.arm_cluster.id
  create_storage_class = true
  storage_class      = "oci-bv-paravirtualized"

  depends_on = [
    oci_containerengine_node_pool.arm_pool,
    null_resource.metrics_server
  ]
}
