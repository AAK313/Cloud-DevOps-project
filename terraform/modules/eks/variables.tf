variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_version" {
  description = "EKS version"
  type        = string
  default     = "1.29"
}

variable "subnet_ids" {
  description = "Subnets for control plane and nodes"
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "desired_capacity" {
  description = "Desired worker nodes"
  type        = number
}

variable "min_size" {
  description = "Minimum worker nodes"
  type        = number
}

variable "max_size" {
  description = "Maximum worker nodes"
  type        = number
}

variable "node_instance_type" {
  description = "Instance type for worker nodes"
  type        = string
  default     = "t3.medium"
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default     = {}
}






