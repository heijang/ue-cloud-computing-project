###############################################################################
# Random Password
###############################################################################

resource "random_password" "db_master" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

###############################################################################
# Secrets Manager — DB Credentials
###############################################################################

resource "aws_secretsmanager_secret" "db_credentials" {
  name        = "${var.env_name}/db-credentials"
  description = "Aurora MySQL master credentials for ${var.env_name}"

  tags = { Name = "${var.env_name}-db-credentials" }
}

resource "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    username    = var.db_username
    password    = random_password.db_master.result
    host        = ""
    reader_host = ""
    port        = "3306"
    dbname      = var.db_name
  })

  lifecycle {
    ignore_changes = [secret_string]
  }
}
