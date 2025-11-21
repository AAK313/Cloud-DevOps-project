# Setup Instructions

## Prerequisites

- AWS account with permissions for VPC, EC2, IAM, EKS, S3, DynamoDB, CloudWatch
- AWS CLI + credentials configured locally
- Terraform >= 1.6
- kubectl + eksctl (optional) + ArgoCD CLI
- Docker + DockerHub account
- Trivy (if enabling image scan stage)
- Git + GitHub repo `CloudDevOpsProject`

## Repository Bootstrap

1. Clone this repo locally.
2. Update `terraform/backend.auto.tfvars` with your S3 bucket and DynamoDB table names for state.
3. Update `terraform/variables.auto.tfvars` (or use CLI vars) with CIDRs, key pair names, AMI IDs, etc.
4. Configure GitHub secrets referenced in `.github/workflows/ci.yml` (see comments inside file).

## Terraform Workflow

```bash
cd terraform
terraform init -backend-config="backend.auto.tfvars"
terraform plan -var-file="variables.auto.tfvars"
terraform apply -var-file="variables.auto.tfvars"
```

Outputs expose VPC IDs, subnet IDs, EKS cluster info, and EC2 public IP for SSH. NAT + ACL settings live in `modules/network`.

## Kubernetes Deployment

1. After Terraform provisions EKS, update your kubeconfig:
   ```bash
   aws eks update-kubeconfig --name <cluster_name> --region <region>
   ```
2. Apply manifests locally (before ArgoCD takes over):
   ```bash
   kubectl apply -f k8s/ivolve/namespace.yaml
   kubectl apply -f k8s/ivolve/deployment.yaml
   kubectl apply -f k8s/ivolve/service.yaml
   ```
3. Once ArgoCD app is synced, future changes should flow through Git commits.

## CI/CD Pipeline

- Workflow file: `.github/workflows/ci.yml`
- Required secrets: `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_REGION`, `DOCKERHUB_USERNAME`, `DOCKERHUB_TOKEN`, `KUBE_CONFIG` (base64), optional `TRIVY_ENABLED` flag.
- Shared logic lives under `vars/` as shell scripts sourced by workflow steps.

## ArgoCD

1. Install ArgoCD in the cluster (if not already).
2. Apply `argocd/application.yaml` to register the app.
3. Confirm project/cluster credentials allow sync to namespace `ivolve`.

## Local Development

- Build and run container locally:
  ```bash
  docker build -t cloud-devops-app:dev .
  docker run -p 5000:5000 cloud-devops-app:dev
  ```
- The Flask app listens on port 5000; feel free to edit files under `app/` and rebuild.

## Troubleshooting

- Terraform backend errors: verify S3 bucket/table exist and IAM perms.
- EKS access: ensure node group IAM roles and aws-auth config map applied.
- GitHub Actions: use `workflow_dispatch` input `dry_run=true` while testing.

Refer to `docs/architecture.md` for system overview.
