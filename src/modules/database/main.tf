###############################################################################
# Data Sources
###############################################################################

data "aws_availability_zones" "available" {
  state = "available"
}

###############################################################################
# DB Subnet Group
###############################################################################

resource "aws_db_subnet_group" "this" {
  name       = "${var.env_name}-aurora-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = { Name = "${var.env_name}-aurora-subnet-group" }
}

###############################################################################
# Security Group — Aurora (inbound 3306 from web SG only)
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
# Aurora MySQL Cluster
###############################################################################

resource "aws_rds_cluster" "this" {
  cluster_identifier = "${var.env_name}-aurora-cluster"
  engine             = "aurora-mysql"
  engine_version     = "8.0.mysql_aurora.3.05.2"

  master_username = var.db_username
  master_password = var.db_password
  database_name   = var.db_name

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.db.id]

  skip_final_snapshot = true
  apply_immediately   = true

  tags = { Name = "${var.env_name}-aurora-cluster" }
}

###############################################################################
# Aurora Instances — Writer (AZ-a) + Reader (AZ-b)
###############################################################################

resource "aws_rds_cluster_instance" "writer" {
  identifier         = "${var.env_name}-aurora-writer"
  cluster_identifier = aws_rds_cluster.this.id
  instance_class     = var.db_instance_class
  engine             = aws_rds_cluster.this.engine
  engine_version     = aws_rds_cluster.this.engine_version
  availability_zone  = data.aws_availability_zones.available.names[0]

  monitoring_interval = 0 # Enhanced monitoring disabled per spec

  tags = { Name = "${var.env_name}-aurora-writer" }
}

resource "aws_rds_cluster_instance" "reader" {
  identifier         = "${var.env_name}-aurora-reader"
  cluster_identifier = aws_rds_cluster.this.id
  instance_class     = var.db_instance_class
  engine             = aws_rds_cluster.this.engine
  engine_version     = aws_rds_cluster.this.engine_version
  availability_zone  = data.aws_availability_zones.available.names[1]

  monitoring_interval = 0

  tags = { Name = "${var.env_name}-aurora-reader" }
}

###############################################################################
# Update Secrets Manager with actual endpoints
###############################################################################

resource "aws_secretsmanager_secret_version" "db_credentials_final" {
  secret_id = var.secret_id
  secret_string = jsonencode({
    username    = var.db_username
    password    = var.db_password
    host        = aws_rds_cluster.this.endpoint
    reader_host = aws_rds_cluster.this.reader_endpoint
    port        = "3306"
    dbname      = var.db_name
  })
}
