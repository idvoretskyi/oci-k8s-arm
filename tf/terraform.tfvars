# ARM OKE Cluster Configuration
# Based on Oracle's straightforward ARM deployment approach

# OCI region - UK South (London) has good ARM availability
region = "uk-london-1"

# Compartment will be read from ~/.oci/config if not specified

# Path to your private key for API access
# private_key_path will be read from ~/.oci/config if not specified

# ARM Kubernetes cluster configuration
# cluster_name will be auto-generated as {username}-arm-oke-cluster
kubernetes_version = "v1.33.1"

# ARM node configuration - scaled to 2 nodes
node_count = 2
node_memory_gb = 6
node_ocpus = 1