/**
 * Outputs for the Monitoring Module
 */

output "monitoring_namespace" {
  description = "The namespace where monitoring components are deployed"
  value       = kubernetes_namespace.monitoring.metadata[0].name
}

output "helm_release_name" {
  description = "Name of the kube-prometheus-stack Helm release"
  value       = helm_release.kube_prometheus_stack.name
}

output "helm_release_version" {
  description = "Version of the deployed kube-prometheus-stack chart"
  value       = helm_release.kube_prometheus_stack.version
}

output "helm_release_status" {
  description = "Status of the kube-prometheus-stack Helm release"
  value       = helm_release.kube_prometheus_stack.status
}

output "prometheus_service_name" {
  description = "Name of the Prometheus service"
  value       = "${var.release_name}-kube-prom-prometheus"
}

output "grafana_service_name" {
  description = "Name of the Grafana service"
  value       = "${var.release_name}-grafana"
}

output "alertmanager_service_name" {
  description = "Name of the Alertmanager service"
  value       = "${var.release_name}-kube-prom-alertmanager"
}

output "grafana_admin_password" {
  description = "Admin password for Grafana (sensitive)"
  value       = var.grafana_admin_password
  sensitive   = true
}

output "grafana_url" {
  description = "URL to access Grafana (if ingress is enabled)"
  value       = var.grafana_ingress_enabled ? "https://${var.grafana_hostname}" : "kubectl port-forward -n ${kubernetes_namespace.monitoring.metadata[0].name} svc/${var.release_name}-grafana 3000:80"
}

output "prometheus_url" {
  description = "URL to access Prometheus (if ingress is enabled)"
  value       = var.prometheus_ingress_enabled ? "https://${var.prometheus_hostname}" : "kubectl port-forward -n ${kubernetes_namespace.monitoring.metadata[0].name} svc/${var.release_name}-kube-prom-prometheus 9090:9090"
}

output "storage_class" {
  description = "Storage class used for persistent volumes"
  value       = var.storage_class
}

output "monitoring_endpoints" {
  description = "Monitoring endpoints for external access"
  value = {
    grafana_service      = "${var.release_name}-grafana.${kubernetes_namespace.monitoring.metadata[0].name}.svc.cluster.local"
    prometheus_service   = "${var.release_name}-kube-prom-prometheus.${kubernetes_namespace.monitoring.metadata[0].name}.svc.cluster.local"
    alertmanager_service = "${var.release_name}-kube-prom-alertmanager.${kubernetes_namespace.monitoring.metadata[0].name}.svc.cluster.local"
  }
}

output "grafana_ingress_hostname" {
  description = "Grafana ingress hostname (if enabled)"
  value       = var.grafana_ingress_enabled ? var.grafana_hostname : null
}

output "prometheus_ingress_hostname" {
  description = "Prometheus ingress hostname (if enabled)"
  value       = var.prometheus_ingress_enabled ? var.prometheus_hostname : null
}