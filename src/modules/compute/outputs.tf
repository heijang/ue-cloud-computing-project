output "instance_ids" {
  description = "IDs of the web tier EC2 instances."
  value       = aws_instance.web[*].id
}

output "web_sg_id" {
  description = "Security group ID of the web tier."
  value       = aws_security_group.web.id
}
