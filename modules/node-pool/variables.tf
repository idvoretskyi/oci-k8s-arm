/**
 * Variables for Node Pool Module
 * 
 * This file declares all the input variables for the node pool module
 */

#######################
# Required Variables  #
#######################

variable "compartment_id" {
  description = "The OCID of the compartment where the node pool will be created"
  type        = string
}

variable "cluster_id" {
  description = "The OCID of the OKE cluster"
  type        = string
}

variable "node_pool_name" {
  description = "Name of the node pool"
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9_-]{0,62}$", var.node_pool_name))
    error_message = "Node pool name must be 1-63 characters long, start with alphanumeric character, and contain only alphanumeric characters, hyphens, and underscores."
  }
}

variable "kubernetes_version" {
  description = "Kubernetes version for the node pool"
  type        = string
}

variable "node_shape" {
  description = "Shape of the nodes in the node pool"
  type        = string
}

variable "worker_subnet_id" {
  description = "OCID of the subnet for worker nodes"
  type        = string
}

variable "node_pool_size" {
  description = "Number of nodes in the node pool"
  type        = number
  default     = 3
  validation {
    condition     = var.node_pool_size > 0 && var.node_pool_size <= 1000
    error_message = "Node pool size must be between 1 and 1000."
  }
}

#######################
# Optional Variables  #
#######################

variable "availability_domain" {
  description = "Specific availability domain to use. If null, will use the first available AD"
  type        = string
  default     = null
}

variable "os_name" {
  description = "Operating system name for the nodes"
  type        = string
  default     = "Oracle Linux"
}

variable "os_version" {
  description = "Operating system version for the nodes"
  type        = string
  default     = "8"
}

variable "node_image_id" {
  description = "Custom image OCID to use for nodes. If null, will use the latest compatible image"
  type        = string
  default     = null
}

variable "boot_volume_size_in_gbs" {
  description = "Size of the boot volume in GB"
  type        = number
  default     = 50
  validation {
    condition     = var.boot_volume_size_in_gbs >= 50 && var.boot_volume_size_in_gbs <= 32768
    error_message = "Boot volume size must be between 50 and 32768 GB."
  }
}

variable "memory_in_gbs" {
  description = "Memory in GB for flex shapes"
  type        = number
  default     = null
}

variable "ocpus" {
  description = "Number of OCPUs for flex shapes"
  type        = number
  default     = null
}

variable "network_security_group_ids" {
  description = "List of network security group OCIDs"
  type        = list(string)
  default     = []
}

variable "kms_key_id" {
  description = "OCID of the KMS key for encryption"
  type        = string
  default     = null
}

variable "enable_pv_encryption_in_transit" {
  description = "Enable persistent volume encryption in transit"
  type        = bool
  default     = false
}

variable "ssh_public_key" {
  description = "SSH public key for node access"
  type        = string
  default     = null
}

variable "tags" {
  description = "Freeform tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "additional_node_labels" {
  description = "Additional Kubernetes labels to apply to nodes"
  type = list(object({
    key   = string
    value = string
  }))
  default = []
}

variable "enable_node_recycling_policy" {
  description = "Enable node recycling policy"
  type        = bool
  default     = false
}

variable "timeouts" {
  description = "Timeout values for node pool operations"
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

#######################
# Autoscaling Variables #
#######################

variable "enable_autoscaling" {
  description = "Enable cluster autoscaling for this node pool"
  type        = bool
  default     = false
}

variable "autoscaling_config" {
  description = "Autoscaling configuration"
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
  description = "Path to kubeconfig file for autoscaler configuration"
  type        = string
  default     = "~/.kube/config"
}
