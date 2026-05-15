resource "azurerm_kubernetes_cluster" "flask_aks" {
  name                = "aks-flask-cicd"
  location            = azurerm_resource_group.flask_rg.location
  resource_group_name = azurerm_resource_group.flask_rg.name
  dns_prefix          = "flask-cicd"

  default_node_pool {
    name       = "default"
    node_count = 2
    vm_size    = "Standard_B2s"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    project = "flask-cicd-app"
    env     = "production"
  }
}

# AKS = Azure's managed Kubernetes.
# Azure runs the control plane (API server, etcd, scheduler) for free.
# You pay for the worker VMs in default_node_pool.
# SystemAssigned identity lets AKS pull from ACR without storing creds.
# azurerm_resource_group.flask_rg.name -> dependency on the RG resource.
