resource "kubernetes_namespace" "app" {
  metadata {
    name = var.namespace
    labels = {
      managed-by = "terraform"
      stage      = "17-tf-branch"
    }
  }
}
