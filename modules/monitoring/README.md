# Monitoring Module for OKE

This module deploys the kube-prometheus-stack Helm chart to provide comprehensive monitoring for Oracle Container Engine for Kubernetes (OKE) clusters.

## Features

- **Prometheus** - Metrics collection and storage with persistent volumes
- **Grafana** - Visualization dashboards with persistence and authentication
- **Alertmanager** - Alert routing and notification management
- **Node Exporter** - Host-level metrics collection
- **Kube State Metrics** - Kubernetes object metrics
- **Default Dashboards** - Pre-configured monitoring dashboards
- **Storage Management** - Configurable persistent storage for all components
- **Ingress Support** - Optional ingress configuration for external access

## Usage

```hcl
module "monitoring" {
  source = "./modules/monitoring"
  
  cluster_id = oci_containerengine_cluster.arm_cluster.id
  
  # Storage configuration
  storage_class = "oci-bv"
  prometheus_storage_size = "50Gi"
  grafana_storage_size = "10Gi"
  
  # Grafana configuration
  grafana_admin_password = "secure-password"
  grafana_service_type = "LoadBalancer"
  
  # Optional ingress
  grafana_ingress_enabled = true
  grafana_hostname = "grafana.yourdomain.com"
  
  tags = {
    Environment = "production"
    Team = "platform"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| kubernetes | >= 2.20.0 |
| helm | >= 2.9.0 |
| oci | >= 4.119.0 |

## Providers

| Name | Version |
|------|---------|
| helm | >= 2.9.0 |
| kubernetes | >= 2.20.0 |
| oci | >= 4.119.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cluster_id | The OCID of the OKE cluster to deploy monitoring to | `string` | n/a | yes |
| monitoring_namespace | Kubernetes namespace for monitoring components | `string` | `"monitoring"` | no |
| release_name | Name of the Helm release | `string` | `"kube-prometheus-stack"` | no |
| chart_version | Version of the kube-prometheus-stack Helm chart | `string` | `"45.7.1"` | no |
| storage_class | Storage class for persistent volumes | `string` | `"oci-bv"` | no |
| prometheus_storage_size | Storage size for Prometheus data | `string` | `"50Gi"` | no |
| prometheus_retention | Data retention period for Prometheus | `string` | `"15d"` | no |
| grafana_admin_password | Admin password for Grafana | `string` | `"admin"` | no |
| grafana_service_type | Service type for Grafana | `string` | `"ClusterIP"` | no |
| grafana_ingress_enabled | Enable ingress for Grafana | `bool` | `false` | no |
| tags | Tags to apply to resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| monitoring_namespace | The namespace where monitoring components are deployed |
| helm_release_name | Name of the kube-prometheus-stack Helm release |
| grafana_service_name | Name of the Grafana service |
| prometheus_service_name | Name of the Prometheus service |
| grafana_url | URL to access Grafana |
| prometheus_url | URL to access Prometheus |
| monitoring_endpoints | All monitoring service endpoints |

## Default Credentials

- **Grafana Admin User**: `admin`
- **Grafana Admin Password**: Value of `grafana_admin_password` variable

## Accessing Services

### Port Forwarding (Default)

```bash
# Access Grafana
kubectl port-forward -n monitoring svc/kube-prometheus-stack-grafana 3000:80

# Access Prometheus
kubectl port-forward -n monitoring svc/kube-prometheus-stack-kube-prom-prometheus 9090:9090

# Access Alertmanager
kubectl port-forward -n monitoring svc/kube-prometheus-stack-kube-prom-alertmanager 9093:9093
```

### LoadBalancer Service

Set `grafana_service_type = "LoadBalancer"` to expose Grafana via OCI Load Balancer.

### Ingress

Enable ingress with:
```hcl
grafana_ingress_enabled = true
grafana_hostname = "grafana.yourdomain.com"
prometheus_ingress_enabled = true
prometheus_hostname = "prometheus.yourdomain.com"
```

## Storage Classes

The module supports OCI Block Volume storage classes:
- `oci-bv` - Standard OCI Block Volume (default)
- `oci-bv-encrypted` - Encrypted OCI Block Volume
- Custom storage classes can be specified

## Security Considerations

1. Change the default Grafana admin password
2. Use ingress with TLS certificates for production
3. Configure network policies to restrict access
4. Use RBAC for fine-grained access control
5. Consider using external authentication (LDAP, OAuth)

## Monitoring Stack Components

| Component | Purpose | Default Port |
|-----------|---------|--------------|
| Prometheus | Metrics collection & storage | 9090 |
| Grafana | Visualization & dashboards | 3000 |
| Alertmanager | Alert routing & notification | 9093 |
| Node Exporter | Node-level metrics | 9100 |
| Kube State Metrics | K8s object metrics | 8080 |

## Examples

See the [examples](./examples/) directory for complete usage examples including:
- Basic monitoring setup
- Production configuration with ingress
- Custom alerting rules
- Integration with external storage