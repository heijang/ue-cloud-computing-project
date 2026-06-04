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
  name                    = var.secret_name
  description             = "RDS MySQL master credentials for ${var.env_name}"
  recovery_window_in_days = 0

  tags = { Name = "${var.env_name}-db-credentials" }
}

# Key schema notes:
#   user / password / host / db  → read by the provided app (app/config/config.js)
#   username / dbname / port     → read by our userdata + db-connect helper
# Both sets are stored so the app and our tooling work without app code changes.
resource "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    user     = var.db_username
    username = var.db_username
    password = random_password.db_master.result
    host     = ""
    port     = "3306"
    db       = var.db_name
    dbname   = var.db_name
  })

  lifecycle {
    ignore_changes = [secret_string]
  }
}
