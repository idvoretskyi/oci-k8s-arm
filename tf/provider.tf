provider "oci" {
  region           = var.region
  tenancy_ocid     = coalesce(var.tenancy_ocid, local.tenancy_ocid)
  user_ocid        = coalesce(var.user_ocid, local.user_ocid)
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
}

# Kubernetes provider for managing K8s resources
provider "kubernetes" {
  host     = "https://${oci_containerengine_cluster.arm_cluster.endpoints[0].public_endpoint}"
  insecure = true
  
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "oci"
    args = [
      "ce", "cluster", "generate-token",
      "--cluster-id", oci_containerengine_cluster.arm_cluster.id
    ]
  }
}

# Helm provider for deploying Helm charts
provider "helm" {
  kubernetes {
    host     = "https://${oci_containerengine_cluster.arm_cluster.endpoints[0].public_endpoint}"
    insecure = true

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "oci"
      args = [
        "ce", "cluster", "generate-token",
        "--cluster-id", oci_containerengine_cluster.arm_cluster.id
      ]
    }
  }
}

terraform {
  required_providers {
    oci = {
      source  = "registry.opentofu.org/oracle/oci"
      version = ">= 7.0.0"
    }
    
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.20.0"
    }
    
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.9.0"
    }
  }
  required_version = ">= 1.5.0"
}
