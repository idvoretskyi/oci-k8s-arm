# Kube-Prometheus-Stack Helm Values Template
# This template is used by Terraform to generate the values.yaml for the Helm chart

# Global settings
fullnameOverride: ""
nameOverride: ""

# Common labels to apply to all resources
commonLabels:
  app.kubernetes.io/managed-by: terraform

# Prometheus configuration
prometheus:
  prometheusSpec:
    # Storage configuration
    storageSpec:
      volumeClaimTemplate:
        spec:
          storageClassName: ${storage_class}
          accessModes: ["ReadWriteOnce"]
          resources:
            requests:
              storage: ${prometheus_storage_size}
    
    # Data retention
    retention: ${prometheus_retention}
    retentionSize: ${prometheus_retention_size}
    
    # Resource limits (minimal for single ARM node)
    resources:
      limits:
        cpu: 200m
        memory: 1Gi
      requests:
        cpu: 100m
        memory: 512Mi
    
    # Security context
    securityContext:
      runAsNonRoot: true
      runAsUser: 65534
      fsGroup: 65534
    
    # Service monitor selector
    serviceMonitorSelectorNilUsesHelmValues: false
    podMonitorSelectorNilUsesHelmValues: false
    ruleSelectorNilUsesHelmValues: false
    
    # Enable admin API for management
    enableAdminAPI: true
    
    # Web configuration
    web:
      pageTitle: "Prometheus - OKE Monitoring"

# Grafana configuration
grafana:
  # Service configuration
  service:
    type: ${grafana_service_type}
    port: 80
    targetPort: 3000
  
  # Admin credentials
  adminPassword: ${grafana_admin_password}
  
  # Persistence
  persistence:
    enabled: ${grafana_persistence_enabled}
    type: pvc
    storageClassName: ${storage_class}
    accessModes:
      - ReadWriteOnce
    size: ${grafana_storage_size}
    finalizers:
      - kubernetes.io/pvc-protection
  
  # Resources (reduced for small ARM nodes)
  resources:
    limits:
      cpu: 200m
      memory: 512Mi
    requests:
      cpu: 100m
      memory: 256Mi
  
  # Security context
  securityContext:
    runAsNonRoot: true
    runAsUser: 472
    fsGroup: 472
  
  # Grafana configuration
  grafana.ini:
    server:
      domain: localhost
      root_url: http://localhost:3000/
    analytics:
      check_for_updates: false
    security:
      admin_user: admin
      admin_password: ${grafana_admin_password}
    users:
      allow_sign_up: false
      auto_assign_org: true
      auto_assign_org_role: Viewer
    auth.anonymous:
      enabled: false
    log:
      mode: console
    grafana_net:
      url: https://grafana.net
  
  # Default dashboards
  defaultDashboardsEnabled: true
  
  # Sidecar for loading dashboards
  sidecar:
    dashboards:
      enabled: true
      label: grafana_dashboard
      labelValue: "1"
      folder: /tmp/dashboards
      searchNamespace: ALL
    datasources:
      enabled: true
      defaultDatasourceEnabled: true
      label: grafana_datasource
      labelValue: "1"

# Alertmanager configuration (disabled for resource constraints)
alertmanager:
  enabled: false

# Node Exporter configuration
nodeExporter:
  enabled: ${node_exporter_enabled}
  resources:
    limits:
      cpu: 100m
      memory: 64Mi
    requests:
      cpu: 50m
      memory: 32Mi

# Kube State Metrics configuration
kubeStateMetrics:
  enabled: ${kube_state_metrics_enabled}
  resources:
    limits:
      cpu: 100m
      memory: 128Mi
    requests:
      cpu: 50m
      memory: 64Mi

# Prometheus Operator configuration
prometheusOperator:
  resources:
    limits:
      cpu: 100m
      memory: 256Mi
    requests:
      cpu: 50m
      memory: 128Mi
  
  # Security context
  securityContext:
    runAsNonRoot: true
    runAsUser: 65534
    fsGroup: 65534

# Default rules and monitoring
defaultRules:
  create: true
  rules:
    alertmanager: true
    etcd: true
    configReloaders: true
    general: true
    k8s: true
    kubeApiserverAvailability: true
    kubeApiserverBurnrate: true
    kubeApiserverHistogram: true
    kubeApiserverSlos: true
    kubelet: true
    kubeProxy: true
    kubePrometheusGeneral: true
    kubePrometheusNodeRecording: true
    kubernetesApps: true
    kubernetesResources: true
    kubernetesStorage: true
    kubernetesSystem: true
    kubeScheduler: true
    kubeStateMetrics: true
    network: true
    node: true
    nodeExporterAlerting: true
    nodeExporterRecording: true
    prometheus: true
    prometheusOperator: true

# Disable components not needed in OKE
kubeApiServer:
  enabled: false

kubeControllerManager:
  enabled: false

coreDns:
  enabled: false

kubeDns:
  enabled: false

kubeEtcd:
  enabled: false

kubeScheduler:
  enabled: false

kubeProxy:
  enabled: false