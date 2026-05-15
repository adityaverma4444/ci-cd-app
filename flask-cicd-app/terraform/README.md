# Terraform layout (tf branch)

This branch demonstrates **Terraform managing Helm releases** instead of Jenkins
running raw `helm upgrade --install` commands. The `main` branch keeps the
plain helm-direct flow so you can compare the two side by side.

```
terraform/
├── k8s/             # Plain K8s objects (namespace, configmap, deployment) - learning sandbox
├── azure/           # Azure RG + AKS - interview / future cloud reference
├── cluster-tools/   # ★ NEW on tf branch: helm_release for ingress-nginx, kube-prom, loki
└── flask-app/       # ★ NEW on tf branch: helm_release pointing at ../../helm/flask-cicd-app
```

## Why two new modules?

| Module | What it replaces | Why split |
|---|---|---|
| `cluster-tools/` | The manual `helm install` commands from Stage 13/14/15 (and the `infra` branch Jenkinsfile) | Cluster-wide infra changes rarely; separate state = safer. |
| `flask-app/`     | The `Deploy with Helm` stage in `main` branch's Jenkinsfile | App is deployed every CI build; needs its own state and frequent applies. |

## Order of operations (one-time bootstrap)

```bash
# 1. Cluster-wide tools (run once when cluster is fresh)
cd terraform/cluster-tools
terraform init
terraform apply -auto-approve

# 2. App deploy (Jenkins runs this on every build)
cd ../flask-app
terraform init
terraform apply -auto-approve \
  -var "image_tag=build-42" \
  -var "mariadb_password=$DB_PASS"
```

## How the Jenkinsfile uses it

The `tf` branch Jenkinsfile replaces the single `Deploy with Helm` stage with three:

| Stage | Command |
|---|---|
| Terraform Init  | `terraform init -input=false` |
| Terraform Plan  | `terraform plan -out=tfplan` (with `TF_VAR_*` env vars from creds) |
| Terraform Apply | `terraform apply tfplan` |

Result: same Helm release as `main` branch, but now there is a **state file**
(`terraform.tfstate`) recording exactly what's deployed. Drift detection,
preview-before-apply, and easy `destroy` come for free.

## Why we did NOT replace Helm

Helm still owns the **chart templates** (`helm/flask-cicd-app/`). Terraform's
`helm_release` resource is just a smarter way to call `helm install`. We kept
both because:

1. Templating in HCL is painful for K8s manifests; Helm is built for it.
2. Switching is one line - Terraform calls our existing chart.
3. Real teams do this exact split: Helm for chart authoring, Terraform for
   release lifecycle in higher environments.

## Comparing main vs tf branch

| Concern | main branch | tf branch |
|---|---|---|
| App deploy | `helm upgrade --install ...` directly in Jenkinsfile | `terraform apply` -> `helm_release` resource |
| Knows what's deployed? | Whatever's currently in K8s | `terraform.tfstate` (single source of truth) |
| Preview before deploy | No (helm does it) | Yes (`terraform plan`) |
| Rollback on partial failure | Manual `helm rollback` | Automatic (`atomic = true`) |
| Destroy whole environment | `helm uninstall` per release | `terraform destroy` (one command) |
| Drift detection | None | `terraform plan` shows it |
