locals {
  default_tags = merge(var.tags, {
    Project     = "CloudDevOpsProject"
    Environment = var.environment
  })
}

module "network" {
  source              = "./modules/network"
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
  private_subnet_cidr_2 = var.private_subnet_cidr_2
  availability_zone   = var.availability_zone
  environment         = var.environment
  eks_cluster_name    = var.eks_cluster_name
  tags                = local.default_tags
}

module "bastion" {
  source              = "./modules/server"
  name                = "bastion"
  vpc_id              = module.network.vpc_id
  subnet_id           = module.network.public_subnet_id
  associate_public_ip = true
  instance_type       = var.public_instance_type
  ami                 = var.ec2_ami
  key_name            = var.key_name
  allowed_ssh_cidrs   = var.allowed_ssh_cidrs
  environment         = var.environment
  cw_alarm_actions    = var.cloudwatch_alarm_actions
  tags                = local.default_tags
}

module "private_app" {
  source              = "./modules/server"
  name                = "private-app"
  vpc_id              = module.network.vpc_id
  subnet_id           = module.network.private_subnet_1_id
  associate_public_ip = false
  instance_type       = var.private_instance_type
  ami                 = var.ec2_ami
  key_name            = var.key_name
  allowed_ssh_cidrs   = var.private_allowed_ssh_cidrs
  environment         = var.environment
  cw_alarm_actions    = var.cloudwatch_alarm_actions
  tags                = local.default_tags
}

module "eks" {
  source               = "./modules/eks"
  cluster_name         = var.eks_cluster_name
  cluster_version      = var.eks_version    
  subnet_ids           = module.network.subnet_ids
  vpc_id               = module.network.vpc_id
  desired_capacity     = var.eks_desired_capacity
  min_size             = var.eks_min_size
  max_size             = var.eks_max_size
  node_instance_type   = var.eks_node_instance_type
  tags                 = local.default_tags
}
