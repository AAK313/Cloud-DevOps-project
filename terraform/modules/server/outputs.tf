output "instance_id" {
  value = aws_instance.this.id
}

output "instance_public_ip" {
  value       = aws_instance.this.public_ip
  description = "Only populated when associate_public_ip is true"
}

output "security_group_id" {
  value = aws_security_group.this.id
}
