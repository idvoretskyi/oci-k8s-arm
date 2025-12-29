output "node_pool_id" {
  value = oci_containerengine_node_pool.node_pool.id
}

output "node_pool_name" {
  value = oci_containerengine_node_pool.node_pool.name
}

output "node_pool_state" {
  value = oci_containerengine_node_pool.node_pool.state
}

output "node_pool_size" {
  value = oci_containerengine_node_pool.node_pool.node_config_details[0].size
}

output "kubernetes_version" {
  value = oci_containerengine_node_pool.node_pool.kubernetes_version
}

output "node_shape" {
  value = oci_containerengine_node_pool.node_pool.node_shape
}

output "node_image_id" {
  value = oci_containerengine_node_pool.node_pool.node_source_details[0].image_id
}

output "node_subnet_ids" {
  value = oci_containerengine_node_pool.node_pool.subnet_ids
}

output "nodes" {
  value = oci_containerengine_node_pool.node_pool.nodes
}

output "node_metadata" {
  value = {
    cluster_id         = oci_containerengine_node_pool.node_pool.cluster_id
    compartment_id     = oci_containerengine_node_pool.node_pool.compartment_id
    kubernetes_version = oci_containerengine_node_pool.node_pool.kubernetes_version
    node_shape         = oci_containerengine_node_pool.node_pool.node_shape
    created_time       = oci_containerengine_node_pool.node_pool.id != "" ? timestamp() : null
  }
}

output "autoscaling_enabled" {
  value = var.enable_autoscaling
}

output "autoscaling_config" {
  value = var.enable_autoscaling ? var.autoscaling_config : null
}
