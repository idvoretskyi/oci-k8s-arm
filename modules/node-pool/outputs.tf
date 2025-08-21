/**
 * Outputs for Node Pool Module
 * 
 * This file defines the outputs that will be returned by the node pool module
 */

output "node_pool_id" {
  description = "OCID of the created node pool"
  value       = oci_containerengine_node_pool.node_pool.id
}

output "node_pool_name" {
  description = "Name of the created node pool"
  value       = oci_containerengine_node_pool.node_pool.name
}

output "node_pool_state" {
  description = "Current state of the node pool"
  value       = oci_containerengine_node_pool.node_pool.state
}

output "node_pool_size" {
  description = "Current size of the node pool"
  value       = oci_containerengine_node_pool.node_pool.node_config_details[0].size
}

output "kubernetes_version" {
  description = "Kubernetes version of the node pool"
  value       = oci_containerengine_node_pool.node_pool.kubernetes_version
}

output "node_shape" {
  description = "Shape of the nodes in the pool"
  value       = oci_containerengine_node_pool.node_pool.node_shape
}

output "node_image_id" {
  description = "Image ID used by the nodes"
  value       = oci_containerengine_node_pool.node_pool.node_source_details[0].image_id
}

output "node_subnet_ids" {
  description = "List of subnet IDs used by the nodes"
  value       = oci_containerengine_node_pool.node_pool.subnet_ids
}

output "nodes" {
  description = "List of nodes in the pool"
  value       = oci_containerengine_node_pool.node_pool.nodes
}

output "node_metadata" {
  description = "Metadata for the node pool"
  value = {
    cluster_id         = oci_containerengine_node_pool.node_pool.cluster_id
    compartment_id     = oci_containerengine_node_pool.node_pool.compartment_id
    kubernetes_version = oci_containerengine_node_pool.node_pool.kubernetes_version
    node_shape         = oci_containerengine_node_pool.node_pool.node_shape
    created_time       = oci_containerengine_node_pool.node_pool.id != "" ? timestamp() : null
  }
}

output "autoscaling_enabled" {
  description = "Whether autoscaling is enabled for this node pool"
  value       = var.enable_autoscaling
}

output "autoscaling_config" {
  description = "Autoscaling configuration if enabled"
  value       = var.enable_autoscaling ? var.autoscaling_config : null
}
