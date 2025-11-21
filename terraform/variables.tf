variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "public_subnet_cidr" {
  description = "CIDR block for public subnet"
  type        = string
}

variable "private_subnet_cidr" {
  description = "CIDR block for private subnet"
  type        = string
}

variable "private_subnet_cidr_2" {
  type = string
  description = "CIDR for second private subnet (e.g. 10.0.3.0/24)"
}

variable "availability_zone" {
  description = "Availability zone"
  type        = string
}

variable "key_name" {
  description = "SSH key name"
  type        = string
}

variable "ec2_ami" {
  description = "AMI ID for EC2 instances"
  type        = string
}

variable "public_instance_type" {
  description = "Instance type for public EC2"
  type        = string
  default     = "t3.micro"
}

variable "private_instance_type" {
  description = "Instance type for private EC2"
  type        = string
  default     = "t3.micro"
}

variable "allowed_ssh_cidrs" {
  description = "CIDR blocks allowed to access bastion"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "private_allowed_ssh_cidrs" {
  description = "CIDR blocks allowed to access private instance"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "cloudwatch_alarm_actions" {
  description = "List of SNS topics/ARNs for CloudWatch alarms"
  type        = list(string)
  default     = []
}

variable "eks_cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "eks_version" {
  description = "EKS version"
  type        = string
  default     = "1.29"
}

variable "eks_desired_capacity" {
  description = "Desired worker nodes"
  type        = number
  default     = 2
}

variable "eks_min_size" {
  description = "Minimum worker nodes"
  type        = number
  default     = 1
}

variable "eks_max_size" {
  description = "Maximum worker nodes"
  type        = number
  default     = 3
}

variable "eks_node_instance_type" {
  description = "Worker node instance type"
  type        = string
  default     = "t3.medium"
}

variable "tags" {
 description = "Additional tags to merge into default_tags"
 type        = map(string)
 default     = {}
}



