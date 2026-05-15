output "release_status" {
  description = "Helm release status (deployed / failed / pending)"
  value       = helm_release.flask_app.status
}

output "release_revision" {
  description = "Helm revision number (increments on every apply that changes anything)"
  value       = helm_release.flask_app.version
}

output "namespace" {
  description = "Namespace where the app is running"
  value       = kubernetes_namespace.app.metadata[0].name
}
