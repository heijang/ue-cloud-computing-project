###############################################################################
# DB Subnet Group
###############################################################################

resource "aws_db_subnet_group" "this" {
  name       = "${var.env_name}-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = { Name = "${var.env_name}-db-subnet-group" }
}

###############################################################################
# Security Group — RDS (inbound 3306 from web SG only)
###############################################################################

resource "aws_security_group" "db" {
  name        = "${var.env_name}-db-sg"
  description = "Allow MySQL from web tier only"
  vpc_id      = var.vpc_id

  tags = { Name = "${var.env_name}-db-sg" }
}

resource "aws_vpc_security_group_ingress_rule" "db_from_web" {
  security_group_id            = aws_security_group.db.id
  referenced_security_group_id = var.web_sg_id
  from_port                    = 3306
  to_port                      = 3306
  ip_protocol                  = "tcp"
  description                  = "MySQL from web tier"
}

resource "aws_vpc_security_group_egress_rule" "db_all_out" {
  security_group_id = aws_security_group.db.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  description       = "Allow all outbound"
}

###############################################################################
# RDS MySQL Instance (single-AZ per spec)
###############################################################################

resource "aws_db_instance" "this" {
  identifier = "${var.env_name}-mysql"
  engine     = "mysql"

  instance_class        = var.db_instance_class
  allocated_storage     = 20
  max_allocated_storage = 100

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.db.id]

  multi_az            = true
  publicly_accessible = false
  skip_final_snapshot = true
  apply_immediately   = true

  monitoring_interval = 0 # Enhanced monitoring disabled per spec

  tags = { Name = "${var.env_name}-mysql" }
}

###############################################################################
# Update Secrets Manager with actual endpoint
###############################################################################

resource "aws_secretsmanager_secret_version" "db_credentials_final" {
  secret_id = var.secret_id
  # user/host/password/db are what the provided app reads; username/dbname/port
  # are what our userdata + db-connect helper read. Store both.
  secret_string = jsonencode({
    user     = var.db_username
    username = var.db_username
    password = var.db_password
    host     = aws_db_instance.this.address
    port     = tostring(aws_db_instance.this.port)
    db       = var.db_name
    dbname   = var.db_name
  })
}
