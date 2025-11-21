# Architecture Overview

## High-Level Flow

1. **Terraform** provisions the network (VPC, subnets, IGW, NAT, NACL), two EC2 instances (bastion/public + private app host), and an EKS cluster with managed node group. State is stored remotely in S3/DynamoDB.
2. **GitHub Actions** builds the Flask application image from `app/`, optionally scans it with Trivy, pushes it to Docker Hub, updates the Kubernetes manifests, and commits them back.
3. **ArgoCD** watches the `k8s/ivolve` folder and syncs the `Deployment` + `Service` into the `ivolve` namespace of the EKS cluster.
4. **Monitoring** is provided by CloudWatch alarms tied to each EC2 instance as well as native EKS metrics (via CloudWatch Container Insights once enabled).

## Components

- **Network Module** – creates the VPC, routing, NAT, and network ACLs so private workloads can reach the internet through the public subnet while remaining unreachable directly.
- **Server Module** – launches curated EC2 instances (one per module call) with IAM profiles for CloudWatch logging/monitoring and security groups for SSH/HTTPS.
- **EKS Module** – stands up the control plane, node group, and supporting IAM roles/policies used by the cluster autoscaler and worker nodes.
- **Kubernetes Manifests** – define the `ivolve` namespace, deployment, and load balancer service for the Flask app.
- **ArgoCD Application** – points to this repository, targeting the `k8s/ivolve` path and automatically syncing to the cluster.
- **GitHub Actions Workflow** – orchestrates build, scan, push, manifest updates, and cleanup in discrete stages while sourcing helper logic from `vars/library.sh`.

## Environments

- **Local** – run `docker build` + `docker run` for quick validation.
- **CI** – GitHub Actions uses containerized runners; secrets configure AWS + DockerHub access.
- **Prod** – EKS cluster in AWS; ArgoCD ensures Git manifests are source of truth.

## Security Considerations

- Secrets are stored in GitHub as encrypted secrets; Terraform backend uses dedicated IAM user/role with least privilege.
- Network ACLs block unwanted inbound traffic on both subnets while allowing the necessary egress.
- CloudWatch alarms notify when CPU > threshold for either EC2 instance; extend with SNS topics.

## Extension Points

- Swap Flask sample app with real workload by updating `app/` and redeploying.
- Add more subnets/AZs by extending `modules/network` variables.
- Introduce service mesh (e.g., AWS App Mesh) or autoscaling policies for EKS via additional manifests/modules.
