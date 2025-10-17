/**
 * Provider version constraints for the Monitoring Module
 */

terraform {
  required_version = ">= 1.0"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.20.0"
    }

    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.9.0"
    }

    oci = {
      source  = "oracle/oci"
      version = ">= 4.119.0"
    }
  }
}