resource "helm_release" "loki_stack" {
  name       = "loki"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "loki-stack"
  version    = "2.10.2"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  wait       = true
  timeout    = 600

  set {
    name  = "grafana.enabled"
    value = "false"
  }

  set {
    name  = "prometheus.enabled"
    value = "false"
  }

  set {
    name  = "loki.persistence.enabled"
    value = "false"
  }

  set {
    name  = "loki.datasource.isDefault"
    value = "false"
  }

  depends_on = [helm_release.kube_prometheus_stack]
}

# explicit depends_on -> Loki goes in only AFTER Grafana exists, so the
# Loki datasource sidecar ConfigMap can be picked up. This is the EXACT
# fix from Stage 15 (Grafana CrashLoopBackOff: "two default datasources")
# but now codified - no human can forget the order.
