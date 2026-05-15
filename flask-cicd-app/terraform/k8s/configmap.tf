resource "kubernetes_config_map" "demo_config" {
  metadata {
    name      = "demo-config"
    namespace = kubernetes_namespace.demo.metadata[0].name
  }

  data = {
    APP_NAME = "terraform-flask-demo"
    APP_ENV  = "learning"
  }
}

# kubernetes_namespace.demo.metadata[0].name -> Terraform dependency reference.
# Terraform automatically creates the namespace BEFORE the configmap.
