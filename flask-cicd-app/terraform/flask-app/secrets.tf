resource "kubernetes_secret" "mariadb" {
  metadata {
    name      = "mariadb-secret"
    namespace = kubernetes_namespace.app.metadata[0].name
  }

  data = {
    "mariadb-root-password" = var.mariadb_password
  }

  type = "Opaque"
}

# Terraform creates the secret BEFORE the helm_release because helm_release
# depends on the namespace, and we explicitly add depends_on in release.tf.
