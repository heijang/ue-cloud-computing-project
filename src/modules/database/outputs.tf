output "db_endpoint" {
  description = "Endpoint address of the RDS MySQL instance."
  value       = aws_db_instance.this.address
}

output "db_sg_id" {
  description = "Security group ID of the RDS instance."
  value       = aws_security_group.db.id
}

output "secret_version_id" {
  description = "ID of the final secret version (populated with the real RDS endpoint). Used to gate web instance launch until the secret has a valid host."
  value       = aws_secretsmanager_secret_version.db_credentials_final.id
}
