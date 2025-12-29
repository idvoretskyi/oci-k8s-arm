variable "cluster_id" {
  type = string
  validation {
    condition     = can(regex("^ocid1\\.cluster\\.", var.cluster_id))
    error_message = "The cluster_id must be a valid OCI cluster OCID."
  }
}

variable "monitoring_namespace" {
  type    = string
  default = "monitoring"
  validation {
    condition     = can(regex("^[a-z0-9]([-a-z0-9]*[a-z0-9])?$", var.monitoring_namespace))
    error_message = "The monitoring_namespace must be a valid Kubernetes namespace name."
  }
}

variable "release_name" {
  type    = string
  default = "kube-prometheus-stack"
}

variable "chart_version" {
  type    = string
  default = "45.7.1"
}

variable "helm_timeout" {
  type    = number
  default = 900
}

variable "storage_class" {
  type    = string
  default = "oci-bv"
}

variable "create_storage_class" {
  type    = bool
  default = false
}

variable "prometheus_storage_size" {
  type    = string
  default = "50Gi"
}

variable "prometheus_retention" {
  type    = string
  default = "15d"
}

variable "prometheus_retention_size" {
  type    = string
  default = "45GiB"
}

variable "grafana_storage_size" {
  type    = string
  default = "10Gi"
}

variable "grafana_persistence_enabled" {
  type    = bool
  default = true
}

variable "alertmanager_storage_size" {
  type    = string
  default = "10Gi"
}

variable "grafana_admin_password" {
  type      = string
  default   = "admin"
  sensitive = true
}

variable "grafana_service_type" {
  type    = string
  default = "ClusterIP"
  validation {
    condition     = contains(["ClusterIP", "NodePort", "LoadBalancer"], var.grafana_service_type)
    error_message = "The grafana_service_type must be one of: ClusterIP, NodePort, LoadBalancer."
  }
}

variable "grafana_ingress_enabled" {
  type    = bool
  default = false
}

variable "grafana_hostname" {
  type    = string
  default = "grafana.example.com"
}

variable "grafana_ingress_annotations" {
  type    = map(string)
  default = {}
}

variable "grafana_ingress_tls_enabled" {
  type    = bool
  default = false
}

variable "prometheus_ingress_enabled" {
  type    = bool
  default = false
}

variable "prometheus_hostname" {
  type    = string
  default = "prometheus.example.com"
}

variable "prometheus_ingress_annotations" {
  type    = map(string)
  default = {}
}

variable "prometheus_ingress_tls_enabled" {
  type    = bool
  default = false
}

variable "ingress_class" {
  type    = string
  default = "nginx"
}

variable "node_exporter_enabled" {
  type    = bool
  default = true
}

variable "kube_state_metrics_enabled" {
  type    = bool
  default = true
}

variable "additional_helm_values" {
  type    = map(string)
  default = {}
}

variable "tags" {
  type    = map(string)
  default = {}
}
