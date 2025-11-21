output "vpc_id" {
  value = module.network.vpc_id
}

output "public_subnet_id" {
  value = module.network.public_subnet_id
}

output "private_subnet_id" {
  value = module.network.private_subnet_1_id
}

output "bastion_public_ip" {
  value       = module.bastion.instance_public_ip
  description = "Public IP of the bastion host"
}

output "private_instance_id" {
  value = module.private_app.instance_id
}

output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  value = module.eks.cluster_endpoint
}
