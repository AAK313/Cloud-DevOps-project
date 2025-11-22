# IVOLVE INTERNSHIP - CloudDevOpsProject

Comprehensive reference implementation that ties Docker, Terraform, EKS, GitHub Actions, and ArgoCD together for a simple Flask application.

## Repository Layout

- `app/` – source pulled from `https://github.com/Ibrahim-Adel15/FinalProject.git`
- `Dockerfile` – builds the Python image
- `k8s/ivolve/` – namespace, deployment, and service manifests
- `terraform/` – root configuration + modules (network, server, eks)
- `argocd/` – ArgoCD application definition
- `.github/workflows/ci.yml` – CI pipeline consuming scripts in `vars/`

## Getting Started

1. **Create GitHub Repo** – run `gh repo create Cloud-DevOps-Project --public` (or via UI) and push this workspace.
2. **Configure Terraform Backend** – `terraform/backend.tf`  and fill in S3 bucket/DynamoDB table names.
3. **Provide Variable Values** – `terraform/variables.tfvars` to and adjust CIDRs, AMIs, key pairs, etc.
4. **Bootstrap Terraform**:
   ```bash
   cd terraform
   terraform init -backend-config=backend.tf
   terraform plan -var-file=variables.tfvars
   terraform apply -var-file=variables.tfvars
   ```
5. **Update kubeconfig** once the EKS cluster is created:
   ```bash
   aws eks update-kubeconfig --name <cluster_name> --region <region>
   ```
6. **Install ArgoCD** (if needed) and apply `argocd/application.yaml` to let it reconcile Kubernetes manifests automatically.

## CI/CD Secrets

Set the following GitHub Actions repository secrets before enabling the pipeline:

- `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_REGION`
- `DOCKERHUB_USERNAME`, `DOCKERHUB_PASSWORD`
- `KUBE_CONFIG` (base64-encoded kubeconfig with access to EKS)
- Optional: `TRIVY_ENABLED=true`

## Setup Instructions

### Prerequisites

- AWS account with permissions for VPC, EC2, IAM, EKS, S3, DynamoDB, CloudWatch
- AWS CLI + credentials configured locally
- Terraform >= 1.6
- kubectl + eksctl (optional) + ArgoCD CLI
- Docker + DockerHub account
- Trivy (if enabling image scan stage)
- Git + GitHub repo `Cloud-DevOps-Project`

### Repository Bootstrap

1. Clone this repo locally.
2. Update `terraform/backend.tf` with your S3 bucket and DynamoDB table names for state.
3. Update `terraform/variables.tfvars` (or use CLI vars) with CIDRs, key pair names, AMI IDs, etc.
4. Configure GitHub secrets referenced in `.github/workflows/pipeline.yml` (see comments inside file).

### Terraform Workflow

```bash
cd terraform
terraform init -backend-config="backend.tf"
terraform plan -var-file="variables.tfvars"
terraform apply -var-file="variables.tfvars"
```

Outputs expose VPC IDs, subnet IDs, EKS cluster info, and EC2 public IP for SSH. NAT + ACL settings live in `modules/network`.

### Kubernetes Deployment

1. After Terraform provisions EKS, update your kubeconfig:
   ```bash
   aws eks update-kubeconfig --name <cluster_name> --region <region>
   ```
2. Apply manifests locally (before ArgoCD takes over):
   ```bash
   kubectl apply -f k8s/namespace.yaml
   kubectl apply -f k8s/deployment.yaml
   kubectl apply -f k8s/service.yaml
   ```
3. Once ArgoCD app is synced, future changes should flow through Git commits.

### CI/CD Pipeline

- Workflow file: `.github/workflows/pipeline.yml`
- Required secrets:  `DOCKERHUB_USERNAME`, `DOCKERHUB_TOKEN`, optional `TRIVY_ENABLED` flag.
- Shared logic lives under `vars/` as shell scripts sourced by workflow steps.

### ArgoCD

1. Install ArgoCD in the cluster (if not already).
2. Apply `argocd/application.yaml` to register the app.
3. Confirm project/cluster credentials allow sync to namespace `ivolve`.

### Local Development

- Build and run container locally:
  ```bash
  docker build -t cloud-devops-app:dev .
  docker run -p 5000:5000 cloud-devops-app:dev
  ```
- The Flask app listens on port 5000; feel free to edit files under `app/` and rebuild.

### Troubleshooting

- Terraform backend errors: verify S3 bucket/table exist and IAM perms.
- EKS access: ensure node group IAM roles and aws-auth config map applied.
- GitHub Actions: use `workflow_dispatch` input `dry_run=true` while testing.

Refer to the Architecture Overview section for system overview.

## Architecture Overview

### High-Level Flow

1. **Terraform** provisions the network (VPC, subnets, IGW, NAT, NACL), two EC2 instances (bastion/public + private app host), and an EKS cluster with managed node group. State is stored remotely in S3/DynamoDB.
2. **GitHub Actions** builds the Flask application image from `app/`, optionally scans it with Trivy, pushes it to Docker Hub, updates the Kubernetes manifests, and commits them back.
3. **ArgoCD** watches the `k8s/ivolve` folder and syncs the `Deployment` + `Service` into the `ivolve` namespace of the EKS cluster.
4. **Monitoring** is provided by CloudWatch alarms tied to each EC2 instance as well as native EKS metrics (via CloudWatch Container Insights once enabled).

### Components

- **Network Module** – creates the VPC, routing, NAT, and network ACLs so private workloads can reach the internet through the public subnet while remaining unreachable directly.
- **Server Module** – launches curated EC2 instances (one per module call) with IAM profiles for CloudWatch logging/monitoring and security groups for SSH/HTTPS.
- **EKS Module** – stands up the control plane, node group, and supporting IAM roles/policies used by the cluster autoscaler and worker nodes.
- **Kubernetes Manifests** – define the `ivolve` namespace, deployment, and load balancer service for the Flask app.
- **ArgoCD Application** – points to this repository, targeting the `k8s/ivolve` path and automatically syncing to the cluster.
- **GitHub Actions Workflow** – orchestrates build, scan, push, manifest updates, and cleanup in discrete stages while sourcing helper logic from `vars/library.sh`.

### Environments

- **Local** – run `docker build` + `docker run` for quick validation.
- **CI** – GitHub Actions uses containerized runners; secrets configure AWS + DockerHub access.
- **Prod** – EKS cluster in AWS; ArgoCD ensures Git manifests are source of truth.

### Security Considerations

- **Secrets** are stored in GitHub as encrypted secrets; Terraform backend uses dedicated IAM user/role with least privilege.
- **Network ACLs** block unwanted inbound traffic on both subnets while allowing the necessary egress.
- **CloudWatch alarms** notify when CPU > threshold for either EC2 instance; extend with SNS topics.

### Extension Points

- Swap Flask sample app with real workload by updating `app/` and redeploying.
- Add more subnets/AZs by extending `modules/network` variables.
- Introduce service mesh (e.g., AWS App Mesh) or autoscaling policies for EKS via additional manifests/modules.
