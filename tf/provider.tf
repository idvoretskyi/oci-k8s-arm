terraform {
  required_version = ">= 1.5.0"
  required_providers {
    oci = {
      source  = "registry.opentofu.org/oracle/oci"
      version = ">= 8.0.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 3.0.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 3.1.1"
    }
  }
}

provider "oci" {
  region           = var.region
  tenancy_ocid     = coalesce(var.tenancy_ocid, local.tenancy_ocid)
  user_ocid        = coalesce(var.user_ocid, local.user_ocid)
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "helm" {
  kubernetes = {
    config_path = "~/.kube/config"
  }
}
