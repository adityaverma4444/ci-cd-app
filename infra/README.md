# Infrastructure Manifests

This directory contains all cluster infrastructure that must exist **before** the
Flask CI/CD app is deployed by Jenkins.

## Quick setup (fresh cluster)

```bash
# 1. Namespaces, secrets, PVC
kubectl apply -f 01-namespaces.yaml
kubectl apply -f 02-secrets.yaml
kubectl apply -f 04-pvc.yaml

# 2. MariaDB
kubectl apply -f 03-mariadb.yaml

# 3. (Optional) Monitoring — see 05-monitoring.yaml for helm command
```

## What lives here

| File | Purpose |
|------|---------|
| `01-namespaces.yaml` | `helm-lab` and `monitoring` namespaces |
| `02-secrets.yaml` | DB password secret for the Flask app |
| `03-mariadb.yaml` | MariaDB deployment + service |
| `04-pvc.yaml` | PersistentVolumeClaim for app data |
| `05-monitoring.yaml` | Prometheus/Grafana helm install instructions |
