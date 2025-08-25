/**
 * Variables for the Monitoring Module
 */

#######################
# Required Variables  #
#######################

variable "cluster_id" {
  description = "The OCID of the OKE cluster to deploy monitoring to"
  type        = string
  validation {
    condition     = can(regex("^ocid1\\.cluster\\.", var.cluster_id))
    error_message = "The cluster_id must be a valid OCI cluster OCID."
  }
}

#######################
# Optional Variables  #
#######################

variable "monitoring_namespace" {
  description = "Kubernetes namespace for monitoring components"
  type        = string
  default     = "monitoring"
  validation {
    condition     = can(regex("^[a-z0-9]([-a-z0-9]*[a-z0-9])?$", var.monitoring_namespace))
    error_message = "The monitoring_namespace must be a valid Kubernetes namespace name."
  }
}

variable "release_name" {
  description = "Name of the Helm release"
  type        = string
  default     = "kube-prometheus-stack"
}

variable "chart_version" {
  description = "Version of the kube-prometheus-stack Helm chart"
  type        = string
  default     = "45.7.1"
}

variable "helm_timeout" {
  description = "Timeout for Helm operations in seconds"
  type        = number
  default     = 900
}

#######################
# Storage Variables   #
#######################

variable "storage_class" {
  description = "Storage class for persistent volumes"
  type        = string
  default     = "oci-bv"
}

variable "create_storage_class" {
  description = "Whether to create the storage class"
  type        = bool
  default     = false
}

variable "prometheus_storage_size" {
  description = "Storage size for Prometheus data"
  type        = string
  default     = "50Gi"
}

variable "prometheus_retention" {
  description = "Data retention period for Prometheus"
  type        = string
  default     = "15d"
}

variable "prometheus_retention_size" {
  description = "Maximum size of Prometheus data before deletion"
  type        = string
  default     = "45GiB"
}

variable "grafana_storage_size" {
  description = "Storage size for Grafana data"
  type        = string
  default     = "10Gi"
}

variable "grafana_persistence_enabled" {
  description = "Enable persistence for Grafana"
  type        = bool
  default     = true
}

variable "alertmanager_storage_size" {
  description = "Storage size for Alertmanager data"
  type        = string
  default     = "10Gi"
}

#######################
# Grafana Variables   #
#######################

variable "grafana_admin_password" {
  description = "Admin password for Grafana"
  type        = string
  default     = "admin"
  sensitive   = true
}

variable "grafana_service_type" {
  description = "Service type for Grafana (ClusterIP, NodePort, LoadBalancer)"
  type        = string
  default     = "ClusterIP"
  validation {
    condition     = contains(["ClusterIP", "NodePort", "LoadBalancer"], var.grafana_service_type)
    error_message = "The grafana_service_type must be one of: ClusterIP, NodePort, LoadBalancer."
  }
}

#######################
# Ingress Variables   #
#######################

variable "grafana_ingress_enabled" {
  description = "Enable ingress for Grafana"
  type        = bool
  default     = false
}

variable "grafana_hostname" {
  description = "Hostname for Grafana ingress"
  type        = string
  default     = "grafana.example.com"
}

variable "grafana_ingress_annotations" {
  description = "Additional annotations for Grafana ingress"
  type        = map(string)
  default     = {}
}

variable "grafana_ingress_tls_enabled" {
  description = "Enable TLS for Grafana ingress"
  type        = bool
  default     = false
}

variable "prometheus_ingress_enabled" {
  description = "Enable ingress for Prometheus"
  type        = bool
  default     = false
}

variable "prometheus_hostname" {
  description = "Hostname for Prometheus ingress"
  type        = string
  default     = "prometheus.example.com"
}

variable "prometheus_ingress_annotations" {
  description = "Additional annotations for Prometheus ingress"
  type        = map(string)
  default     = {}
}

variable "prometheus_ingress_tls_enabled" {
  description = "Enable TLS for Prometheus ingress"
  type        = bool
  default     = false
}

variable "ingress_class" {
  description = "Ingress class to use"
  type        = string
  default     = "nginx"
}

#######################
# Component Variables #
#######################

variable "node_exporter_enabled" {
  description = "Enable node exporter"
  type        = bool
  default     = true
}

variable "kube_state_metrics_enabled" {
  description = "Enable kube-state-metrics"
  type        = bool
  default     = true
}

#######################
# Additional Variables#
#######################

variable "additional_helm_values" {
  description = "Additional Helm values to pass to kube-prometheus-stack"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}