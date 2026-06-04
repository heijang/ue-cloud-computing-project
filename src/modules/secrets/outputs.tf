output "secret_arn" {
  description = "ARN of the Secrets Manager secret."
  value       = aws_secretsmanager_secret.db_credentials.arn
}

output "secret_id" {
  description = "ID of the Secrets Manager secret (used to update the version)."
  value       = aws_secretsmanager_secret.db_credentials.id
}

output "secret_name" {
  description = "Name of the Secrets Manager secret."
  value       = aws_secretsmanager_secret.db_credentials.name
}

output "db_username" {
  description = "Master username for the Aurora cluster."
  value       = var.db_username
}

output "db_password" {
  description = "Master password for the Aurora cluster."
  value       = random_password.db_master.result
  sensitive   = true
}

output "db_name" {
  description = "Name of the default database."
  value       = var.db_name
}
