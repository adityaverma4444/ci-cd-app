resource "helm_release" "flask_app" {
  name             = var.release_name
  chart            = var.chart_path
  namespace        = kubernetes_namespace.app.metadata[0].name
  create_namespace = false
  wait             = true
  timeout          = 600
  atomic           = true

  set {
    name  = "image.repository"
    value = var.image_repo
  }

  set {
    name  = "image.tag"
    value = var.image_tag
  }

  set {
    name  = "ingress.enabled"
    value = "true"
  }

  set {
    name  = "alertRules.enabled"
    value = "true"
  }

  set {
    name  = "rbac.create"
    value = "true"
  }

  set_sensitive {
    name  = "mariadb.auth.rootPassword"
    value = var.mariadb_password
  }

  depends_on = [kubernetes_secret.mariadb]
}

# helm_release = "Terraform, please run `helm upgrade --install` for me".
# atomic=true       -> if upgrade fails mid-way, automatically roll back.
# wait=true         -> block until all pods are Ready.
# set_sensitive {}  -> same as `set {}` but value never appears in plan output.
