variable "compartment_id" {
  type = string
}

variable "cluster_id" {
  type = string
}

variable "node_pool_name" {
  type = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9_-]{0,62}$", var.node_pool_name))
    error_message = "Node pool name must be 1-63 characters long, start with alphanumeric character, and contain only alphanumeric characters, hyphens, and underscores."
  }
}

variable "kubernetes_version" {
  type = string
}

variable "node_shape" {
  type = string
}

variable "worker_subnet_id" {
  type = string
}

variable "node_pool_size" {
  type    = number
  default = 3
  validation {
    condition     = var.node_pool_size > 0 && var.node_pool_size <= 1000
    error_message = "Node pool size must be between 1 and 1000."
  }
}

variable "availability_domain" {
  type    = string
  default = null
}

variable "os_name" {
  type    = string
  default = "Oracle Linux"
}

variable "os_version" {
  type    = string
  default = "8"
}

variable "node_image_id" {
  type    = string
  default = null
}

variable "boot_volume_size_in_gbs" {
  type    = number
  default = 50
  validation {
    condition     = var.boot_volume_size_in_gbs >= 50 && var.boot_volume_size_in_gbs <= 32768
    error_message = "Boot volume size must be between 50 and 32768 GB."
  }
}

variable "memory_in_gbs" {
  type    = number
  default = null
}

variable "ocpus" {
  type    = number
  default = null
}

variable "network_security_group_ids" {
  type    = list(string)
  default = []
}

variable "kms_key_id" {
  type    = string
  default = null
}

variable "enable_pv_encryption_in_transit" {
  type    = bool
  default = true
}

variable "ssh_public_key" {
  type    = string
  default = null
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "additional_node_labels" {
  type = list(object({
    key   = string
    value = string
  }))
  default = []
}

variable "enable_node_recycling_policy" {
  type    = bool
  default = false
}

variable "timeouts" {
  type = object({
    create = number
    update = number
    delete = number
  })
  default = {
    create = 60
    update = 60
    delete = 60
  }
}

variable "enable_autoscaling" {
  type    = bool
  default = false
}

variable "autoscaling_config" {
  type = object({
    min_nodes = number
    max_nodes = number
  })
  default = {
    min_nodes = 1
    max_nodes = 10
  }
  validation {
    condition     = var.autoscaling_config.min_nodes <= var.autoscaling_config.max_nodes
    error_message = "min_nodes must be less than or equal to max_nodes."
  }
  validation {
    condition     = var.autoscaling_config.min_nodes >= 0 && var.autoscaling_config.max_nodes >= 1
    error_message = "min_nodes must be >= 0 and max_nodes must be >= 1."
  }
}

variable "kubeconfig_path" {
  type    = string
  default = "~/.kube/config"
}
