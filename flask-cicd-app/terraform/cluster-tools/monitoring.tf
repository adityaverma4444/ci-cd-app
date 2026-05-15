resource "helm_release" "kube_prometheus_stack" {
  name       = "kube-prom"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "58.2.1"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  wait       = true
  timeout    = 900

  set {
    name  = "alertmanager.enabled"
    value = "false"
  }

  set {
    name  = "prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues"
    value = "false"
  }

  set {
    name  = "prometheus.prometheusSpec.ruleSelectorNilUsesHelmValues"
    value = "false"
  }

  set {
    name  = "grafana.adminPassword"
    value = "admin"
  }
}

# Stage 14 installed this with: helm upgrade --install kube-prom ...
# Now it's a Terraform resource. `terraform apply` is idempotent -
# re-running won't reinstall, only changes diffs are pushed.
