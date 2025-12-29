variable "region" {
  type    = string
  default = "uk-london-1"
}

variable "tenancy_ocid" {
  type    = string
  default = null
}

variable "compartment_ocid" {
  type    = string
  default = null
}

variable "user_ocid" {
  type    = string
  default = null
}

variable "fingerprint" {
  type    = string
  default = null
}

variable "private_key_path" {
  type    = string
  default = null
}

variable "cluster_name" {
  type    = string
  default = null
}

variable "kubernetes_version" {
  type    = string
  default = "v1.34.1"
}

variable "node_count" {
  type    = number
  default = 1
}

variable "node_memory_gb" {
  type    = number
  default = 8
}

variable "node_ocpus" {
  type    = number
  default = 2
}

variable "username" {
  type    = string
  default = null
}

variable "grafana_admin_password" {
  type      = string
  default   = "admin123!"
  sensitive = true
}
