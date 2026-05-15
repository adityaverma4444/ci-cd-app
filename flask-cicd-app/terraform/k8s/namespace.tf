resource "kubernetes_namespace" "demo" {
  metadata {
    name = "terraform-demo"
    labels = {
      managed-by = "terraform"
      stage      = "17"
      owner      = "aditya"
    }
  }
}

# resource "TYPE" "LOCAL_NAME" = "create this thing, I'll call it 'demo' in my code"
# metadata.name = the actual K8s name
# labels        = K8s labels (helps prove Terraform created it)
