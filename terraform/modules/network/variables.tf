variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnet_cidr" {
  description = "CIDR for the public subnet"
  type        = string
}

variable "private_subnet_cidr" {
  description = "CIDR for the private subnet"
  type        = string
}

variable "private_subnet_cidr_2" {
  type = string
  description = "CIDR for second private subnet (e.g. 10.0.3.0/24)"
}


variable "availability_zone" {
  description = "Availability zone for subnets"
  type        = string
}

variable "environment" {
  description = "Environment name (dev/stage/prod)"
  type        = string
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}

variable "eks_cluster_name" {
  description = "EKS cluster name for subnet tagging"
  type        = string
  default     = ""
}
