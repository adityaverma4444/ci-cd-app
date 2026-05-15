# Terraform layout (tf branch)

This branch demonstrates **Terraform managing Helm releases** instead of
Jenkins running raw `helm upgrade --install` commands.

The `main` branch keeps the plain helm-direct flow plus learning sandboxes
(`terraform/k8s/`, `terraform/azure/`). Those are intentionally NOT on this
branch - it stays focused on the real production-style flow.

```
terraform/
├── cluster-tools/   # helm_release for ingress-nginx, kube-prom, loki
└── flask-app/       # helm_release pointing at ../../helm/flask-cicd-app
```

## What each module does

| Module | Replaces | Why |
|---|---|---|
| `cluster-tools/` | Manual `helm install` of ingress + monitoring + loki (the `infra` branch on main) | Cluster-wide tools change rarely; one shared state for them all. |
| `flask-app/` | The `Deploy with Helm` stage in `main` branch's Jenkinsfile | App is deployed every CI build; needs its own state. |

## Bootstrap order

```bash
# 1. Run once when cluster is fresh
cd terraform/cluster-tools
terraform init
terraform apply -auto-approve

# 2. Jenkins runs this on every build
cd ../flask-app
terraform init
terraform apply -auto-approve \
  -var "image_tag=build-42" \
  -var "mariadb_password=$DB_PASS"
```

## Jenkinsfile changes vs main

The `Deploy with Helm` single stage is replaced with three:

| Stage | Command |
|---|---|
| Terraform Init  | `terraform init -input=false` |
| Terraform Plan  | `terraform plan -out=tfplan` (TF_VAR_* env vars from Jenkins creds) |
| Terraform Apply | `terraform apply tfplan` |

Same final result (Flask app + MariaDB in `helm-lab` namespace) but now
backed by a `terraform.tfstate` file, with `terraform plan` showing diffs
before apply, and `terraform destroy` cleaning everything in one command.

## Why we did NOT replace Helm

Helm still owns the **chart templates** (`helm/flask-cicd-app/`).
Terraform's `helm_release` resource just calls `helm install` for us.
We kept both because:

1. Templating in HCL is painful for K8s manifests; Helm is built for it.
2. Switching is one line - Terraform calls our existing chart.
3. Real teams do this exact split: Helm for chart authoring, Terraform for
   release lifecycle in higher environments.

## Comparing main vs tf branch

| Concern | main branch | tf branch |
|---|---|---|
| App deploy | `helm upgrade --install ...` directly in Jenkinsfile | `terraform apply` → `helm_release` resource |
| Knows what's deployed? | Whatever's in K8s right now | `terraform.tfstate` (single source of truth) |
| Preview before deploy | No | Yes (`terraform plan`) |
| Rollback on partial failure | Manual `helm rollback` | Automatic (`atomic = true`) |
| Tear down everything | `helm uninstall` per release | `terraform destroy` (one command) |
| Drift detection | None | `terraform plan` shows it |
