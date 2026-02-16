# ARM OKE Cluster Configuration
# Based on Oracle's straightforward ARM deployment approach

# OCI region - UK South (London) has good ARM availability
region = "uk-london-1"

# Compartment will be read from ~/.oci/config if not specified

# Path to your private key for API access
# private_key_path will be read from ~/.oci/config if not specified

# ARM Kubernetes cluster configuration
# cluster_name will be auto-generated as {username}-arm-oke-cluster
# kubernetes_version is auto-detected (latest available) unless overridden

# ARM node configuration - 3 nodes with encryption in transit disabled  
node_count     = 3
node_memory_gb = 6
node_ocpus     = 1