resource "helm_release" "ingress_nginx" {
  name             = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  version          = "4.10.0"
  namespace        = kubernetes_namespace.ingress.metadata[0].name
  create_namespace = false
  wait             = true
  timeout          = 600

  set {
    name  = "controller.service.type"
    value = "NodePort"
  }

  set {
    name  = "controller.service.nodePorts.http"
    value = "30080"
  }

  set {
    name  = "controller.admissionWebhooks.enabled"
    value = "false"
  }
}

# Same chart Stage 13 installed by hand. Now Terraform owns it.
# admissionWebhooks disabled because Docker-Desktop K8s sometimes can't
# reach the webhook service quickly enough (saves debugging time).
