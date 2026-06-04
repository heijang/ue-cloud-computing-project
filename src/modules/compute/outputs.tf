output "web_sg_id" {
  description = "Security group ID of the web tier."
  value       = aws_security_group.web.id
}

output "asg_name" {
  description = "Name of the Auto Scaling Group."
  value       = aws_autoscaling_group.web.name
}

output "ssh_key_name" {
  description = "Name of the generated EC2 key pair (null when SSH is disabled)."
  value       = var.enable_ssh ? aws_key_pair.web[0].key_name : null
}

output "ssh_private_key_path" {
  description = "Local path to the generated private key .pem (null when SSH is disabled)."
  value       = var.enable_ssh ? local_sensitive_file.ssh_private_key[0].filename : null
}
