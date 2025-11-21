# CloudDevOpsProject

Comprehensive reference implementation that ties Docker, Terraform, EKS, GitHub Actions, and ArgoCD together for a simple Flask application.

## Repository Layout

- `app/` – source pulled from `https://github.com/Ibrahim-Adel15/FinalProject.git`
- `Dockerfile` – builds the Python image
- `k8s/ivolve/` – namespace, deployment, and service manifests
- `terraform/` – root configuration + modules (network, server, eks)
- `argocd/` – ArgoCD application definition
- `.github/workflows/ci.yml` – CI pipeline consuming scripts in `vars/`
- `docs/` – setup and architecture notes

## Getting Started

1. **Create GitHub Repo** – run `gh repo create CloudDevOpsProject --public` (or via UI) and push this workspace.
2. **Configure Terraform Backend** – copy `terraform/backend.auto.tfvars.example` to `backend.auto.tfvars` and fill in S3 bucket/DynamoDB table names.
3. **Provide Variable Values** – copy `terraform/variables.auto.tfvars.example` to `variables.auto.tfvars` and adjust CIDRs, AMIs, key pairs, etc.
4. **Bootstrap Terraform**:
   ```bash
   cd terraform
   terraform init -backend-config=backend.auto.tfvars
   terraform plan -var-file=variables.auto.tfvars
   terraform apply -var-file=variables.auto.tfvars
   ```
5. **Update kubeconfig** once the EKS cluster is created:
   ```bash
   aws eks update-kubeconfig --name <cluster_name> --region <region>
   ```
6. **Install ArgoCD** (if needed) and apply `argocd/application.yaml` to let it reconcile Kubernetes manifests automatically.

## CI/CD Secrets

Set the following GitHub Actions repository secrets before enabling the pipeline:

- `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_REGION`
- `DOCKERHUB_USERNAME`, `DOCKERHUB_TOKEN`
- `KUBE_CONFIG` (base64-encoded kubeconfig with access to EKS)
- Optional: `TRIVY_ENABLED=true`

## Documentation

Detailed setup walkthrough and architecture diagrams live under `docs/`.
