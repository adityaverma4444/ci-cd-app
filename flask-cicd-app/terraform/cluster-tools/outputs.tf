output "ingress_status" {
  value = helm_release.ingress_nginx.status
}

output "prometheus_status" {
  value = helm_release.kube_prometheus_stack.status
}

output "loki_status" {
  value = helm_release.loki_stack.status
}

output "next_step" {
  value = "After this completes, run: cd ../flask-app && terraform init && terraform apply"
}
