# Terraform layout (Stage 17)

Each subfolder is an independent Terraform **root module** with its own state.
This is the same pattern real teams use: separate state per environment / cloud
so a mistake in one folder can't blast resources in another.

```
terraform/
├── k8s/      # Local Docker-Desktop K8s resources (namespace, configmap, deployment)
└── azure/    # Azure resources (Resource Group, AKS cluster) - plan-only / interview ref
```

## How to run each module

### terraform/k8s (real, runs against your local cluster)
```bash
cd terraform/k8s
terraform init
terraform plan
terraform apply -auto-approve
terraform destroy -auto-approve   # cleanup
```

### terraform/azure (needs `az login` first)
```bash
cd terraform/azure
terraform init
terraform plan                    # safe - just shows what WOULD be created
terraform apply                   # only run if you actually want to spend money
```

## Why split them?

1. **Blast radius** - destroying k8s/ can never touch Azure infra and vice-versa.
2. **State files** - each folder gets its own `terraform.tfstate`. Smaller state =
   faster plans, fewer lock conflicts when teams collaborate.
3. **Different providers** - k8s/ only needs the `kubernetes` provider, azure/
   only needs `azurerm`. Less plugin download per module.
4. **CI/CD friendly** - Jenkins can run `terraform -chdir=terraform/k8s plan` for
   PRs that touch app infra without re-planning Azure.
