locals {
  resource_name_prefix = var.monitoring_namespace
  monitoring_tags = {
    "ResourceType" = "Monitoring"
    "Component"    = "KubePrometheusStack"
    "AutomatedBy"  = "OpenTofu"
    "CreatedAt"    = timestamp()
  }
  all_tags             = merge(var.tags, local.monitoring_tags)
  grafana_service_type = var.grafana_ingress_enabled ? "ClusterIP" : var.grafana_service_type
}

resource "kubernetes_namespace_v1" "monitoring" {
  metadata {
    name = var.monitoring_namespace
    labels = {
      name                           = var.monitoring_namespace
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
}

resource "kubernetes_storage_class_v1" "monitoring_storage" {
  count = var.create_storage_class ? 1 : 0

  metadata {
    name = var.storage_class
  }

  storage_provisioner    = "blockvolume.csi.oraclecloud.com"
  reclaim_policy         = "Retain"
  allow_volume_expansion = true
  volume_binding_mode    = "WaitForFirstConsumer"

  parameters = {
    "fsType"         = "ext4"
    "attachmentType" = "paravirtualized"
  }
}

resource "helm_release" "kube_prometheus_stack" {
  name       = var.release_name
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = var.chart_version
  namespace  = kubernetes_namespace_v1.monitoring.metadata[0].name

  wait          = true
  wait_for_jobs = true
  timeout       = var.helm_timeout

  values = [
    templatefile("${path.module}/values.yaml.tpl", {
      storage_class               = var.storage_class
      prometheus_storage_size     = var.prometheus_storage_size
      prometheus_retention        = var.prometheus_retention
      prometheus_retention_size   = var.prometheus_retention_size
      grafana_service_type        = local.grafana_service_type
      grafana_admin_password      = var.grafana_admin_password
      grafana_persistence_enabled = var.grafana_persistence_enabled
      grafana_storage_size        = var.grafana_storage_size
      alertmanager_storage_size   = var.alertmanager_storage_size
      node_exporter_enabled       = var.node_exporter_enabled
      kube_state_metrics_enabled  = var.kube_state_metrics_enabled
    })
  ]

  depends_on = [
    kubernetes_namespace_v1.monitoring,
    kubernetes_storage_class_v1.monitoring_storage
  ]
}

resource "kubernetes_ingress_v1" "grafana_ingress" {
  count = var.grafana_ingress_enabled ? 1 : 0

  metadata {
    name      = "${var.release_name}-grafana"
    namespace = kubernetes_namespace_v1.monitoring.metadata[0].name
    annotations = merge({
      "kubernetes.io/ingress.class"                = var.ingress_class
      "nginx.ingress.kubernetes.io/rewrite-target" = "/"
    }, var.grafana_ingress_annotations)
  }

  spec {
    dynamic "tls" {
      for_each = var.grafana_ingress_tls_enabled ? [1] : []
      content {
        hosts       = [var.grafana_hostname]
        secret_name = "${var.release_name}-grafana-tls"
      }
    }

    rule {
      host = var.grafana_hostname
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "${var.release_name}-grafana"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }

  depends_on = [helm_release.kube_prometheus_stack]
}

resource "kubernetes_ingress_v1" "prometheus_ingress" {
  count = var.prometheus_ingress_enabled ? 1 : 0

  metadata {
    name      = "${var.release_name}-prometheus"
    namespace = kubernetes_namespace_v1.monitoring.metadata[0].name
    annotations = merge({
      "kubernetes.io/ingress.class"                = var.ingress_class
      "nginx.ingress.kubernetes.io/rewrite-target" = "/"
    }, var.prometheus_ingress_annotations)
  }

  spec {
    dynamic "tls" {
      for_each = var.prometheus_ingress_tls_enabled ? [1] : []
      content {
        hosts       = [var.prometheus_hostname]
        secret_name = "${var.release_name}-prometheus-tls"
      }
    }

    rule {
      host = var.prometheus_hostname
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "${var.release_name}-kube-prom-prometheus"
              port {
                number = 9090
              }
            }
          }
        }
      }
    }
  }

  depends_on = [helm_release.kube_prometheus_stack]
}
