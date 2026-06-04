output "db_endpoint" {
  description = "Endpoint address of the RDS MySQL instance."
  value       = aws_db_instance.this.address
}

output "db_sg_id" {
  description = "Security group ID of the RDS instance."
  value       = aws_security_group.db.id
}
