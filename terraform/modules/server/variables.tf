variable "name" {
  description = "Friendly name for the instance"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC where resources will be created"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for the instance"
  type        = string
}

variable "associate_public_ip" {
  description = "Whether to assign a public IP"
  type        = bool
  default     = false
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "ami" {
  description = "AMI ID for the instance"
  type        = string
}

variable "key_name" {
  description = "EC2 key pair name"
  type        = string
}

variable "allowed_ssh_cidrs" {
  description = "List of CIDR blocks allowed for SSH"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "environment" {
  description = "Environment (dev/stage/prod)"
  type        = string
}

variable "cw_alarm_actions" {
  description = "Optional SNS topics or actions for CloudWatch alarm"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}
