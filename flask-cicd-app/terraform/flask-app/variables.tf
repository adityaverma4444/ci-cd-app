variable "namespace" {
  description = "Kubernetes namespace for the Flask app release"
  type        = string
  default     = "helm-lab"
}

variable "release_name" {
  description = "Helm release name (becomes the prefix for all created resources)"
  type        = string
  default     = "flask-cicd-helm2"
}

variable "image_tag" {
  description = "Docker image tag for the Flask app (Jenkins overrides this with build number)"
  type        = string
  default     = "latest"
}

variable "image_repo" {
  description = "Docker image repository"
  type        = string
  default     = "adityaverma4444/flask-cicd-app"
}

variable "mariadb_password" {
  description = "MariaDB root password (Jenkins must inject this from credentials)"
  type        = string
  sensitive   = true
  default     = "changeme"
}

variable "chart_path" {
  description = "Path to the local Helm chart, relative to this folder"
  type        = string
  default     = "../../helm/flask-cicd-app"
}
