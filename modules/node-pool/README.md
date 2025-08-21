# Node Pool Module

This module creates a node pool for an Oracle Kubernetes Engine (OKE) cluster with enhanced features and configuration options.

## Features

- ✅ Support for multiple availability domains
- ✅ Node pool capacity management
- ✅ Automatic OS image selection
- ✅ Node labeling and tainting
- ✅ Resource management with proper dependencies
- ✅ Support for both standard and flex shapes
- ✅ ARM64 and AMD64 architecture support
- ✅ Optional cluster autoscaling integration
- ✅ Comprehensive validation and error handling

## Usage

```hcl
module "node_pool" {
  source = "./modules/node-pool"
  
  # Required variables
  compartment_id      = var.compartment_id
  cluster_id          = oci_containerengine_cluster.cluster.id
  node_pool_name      = "my-node-pool"
  kubernetes_version  = "v1.33.0"
  node_shape          = "VM.Standard.A1.Flex"
  worker_subnet_id    = oci_core_subnet.worker_subnet.id
  node_pool_size      = 3
  
  # Optional flex shape configuration
  memory_in_gbs = 8
  ocpus         = 2
  
  # Optional features
  enable_autoscaling = true
  autoscaling_config = {
    min_nodes = 1
    max_nodes = 10
  }
  
  # Optional node customization
  additional_node_labels = [
    {
      key   = "environment"
      value = "production"
    }
  ]
  
  tags = {
    Environment = "production"
    Team        = "platform"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| oci | >= 7.0.0 |

## Providers

| Name | Version |
|------|---------|
| oci | >= 7.0.0 |
| null | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| compartment_id | The OCID of the compartment | `string` | n/a | yes |
| cluster_id | The OCID of the OKE cluster | `string` | n/a | yes |
| node_pool_name | Name of the node pool | `string` | n/a | yes |
| kubernetes_version | Kubernetes version | `string` | n/a | yes |
| node_shape | Shape of the nodes | `string` | n/a | yes |
| worker_subnet_id | OCID of the worker subnet | `string` | n/a | yes |
| node_pool_size | Number of nodes | `number` | `3` | no |
| memory_in_gbs | Memory in GB for flex shapes | `number` | `null` | no |
| ocpus | Number of OCPUs for flex shapes | `number` | `null` | no |
| enable_autoscaling | Enable cluster autoscaling | `bool` | `false` | no |
| autoscaling_config | Autoscaling configuration | `object` | `{min_nodes=1, max_nodes=10}` | no |

## Outputs

| Name | Description |
|------|-------------|
| node_pool_id | OCID of the created node pool |
| node_pool_name | Name of the created node pool |
| node_pool_state | Current state of the node pool |
| node_pool_size | Current size of the node pool |
| kubernetes_version | Kubernetes version of the node pool |
| node_shape | Shape of the nodes in the pool |

## Examples

### Basic Node Pool

```hcl
module "basic_node_pool" {
  source = "./modules/node-pool"
  
  compartment_id     = var.compartment_id
  cluster_id         = oci_containerengine_cluster.cluster.id
  node_pool_name     = "basic-pool"
  kubernetes_version = "v1.33.0"
  node_shape         = "VM.Standard.E4.Flex"
  worker_subnet_id   = oci_core_subnet.worker_subnet.id
  node_pool_size     = 2
  memory_in_gbs      = 16
  ocpus              = 2
}
```

### ARM-based Node Pool with Autoscaling

```hcl
module "arm_node_pool" {
  source = "./modules/node-pool"
  
  compartment_id     = var.compartment_id
  cluster_id         = oci_containerengine_cluster.cluster.id
  node_pool_name     = "arm-pool"
  kubernetes_version = "v1.33.0"
  node_shape         = "VM.Standard.A1.Flex"
  worker_subnet_id   = oci_core_subnet.worker_subnet.id
  node_pool_size     = 3
  memory_in_gbs      = 8
  ocpus              = 2
  
  enable_autoscaling = true
  autoscaling_config = {
    min_nodes = 1
    max_nodes = 10
  }
  
  additional_node_labels = [
    {
      key   = "node.kubernetes.io/instance-type"
      value = "arm64"
    }
  ]
}
```

## Notes

- For flex shapes, both `memory_in_gbs` and `ocpus` must be specified
- ARM shapes (A1.Flex) require ARM-compatible container images
- Autoscaling requires cluster autoscaler to be installed in the cluster
- The module automatically selects the latest compatible OS image if not specified
