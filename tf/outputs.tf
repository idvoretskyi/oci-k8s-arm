output "cluster_id" {
  value = oci_containerengine_cluster.arm_cluster.id
}

output "cluster_name" {
  value = oci_containerengine_cluster.arm_cluster.name
}

output "api_endpoint" {
  value     = oci_containerengine_cluster.arm_cluster.endpoints[0].kubernetes
  sensitive = true
}

output "vcn_id" {
  value = oci_core_vcn.vcn.id
}

output "arm_node_pool_id" {
  value = oci_containerengine_node_pool.arm_pool.id
}

output "kubeconfig_command" {
  value = "oci ce cluster create-kubeconfig --cluster-id ${oci_containerengine_cluster.arm_cluster.id} --file ~/.kube/config --region ${var.region} --token-version 2.0.0 --context-name ${oci_containerengine_cluster.arm_cluster.name}"
}

output "cluster_region" {
  value = var.region
}

output "node_shape" {
  value = "VM.Standard.A1.Flex"
}

output "architecture" {
  value = "arm64"
}
