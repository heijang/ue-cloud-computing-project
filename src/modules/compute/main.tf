###############################################################################
# Latest Ubuntu 24.04 LTS AMI
###############################################################################

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

###############################################################################
# Web Tier Security Group — only ALB can reach port 80
###############################################################################

resource "aws_security_group" "web" {
  name        = "${var.env_name}-web-sg"
  description = "Allow HTTP from ALB only"
  vpc_id      = var.vpc_id

  ingress {
    description     = "HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [var.alb_sg_id]
  }

  dynamic "ingress" {
    for_each = var.enable_ssh ? [1] : []
    content {
      description = "SSH for inspection/debugging"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [var.ssh_ingress_cidr]
    }
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.env_name}-web-sg" }
}

###############################################################################
# SSH Key Pair (generated + uploaded; private key written locally as .pem)
# Works in both AWS Academy lab and personal accounts — no IAM role required.
###############################################################################

resource "tls_private_key" "ssh" {
  count     = var.enable_ssh ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "web" {
  count      = var.enable_ssh ? 1 : 0
  key_name   = "${var.env_name}-web-key"
  public_key = tls_private_key.ssh[0].public_key_openssh

  tags = { Name = "${var.env_name}-web-key" }
}

resource "local_sensitive_file" "ssh_private_key" {
  count           = var.enable_ssh ? 1 : 0
  content         = tls_private_key.ssh[0].private_key_pem
  filename        = coalesce(var.ssh_key_output_path, "${path.root}/${var.env_name}-web-key.pem")
  file_permission = "0400"
}

###############################################################################
# IAM Instance Profile
#
# AWS Academy: pass instance_profile_name = "LabInstanceProfile" (lab forbids
#   creating IAM roles, so nothing is created here).
# Personal account: leave instance_profile_name = null and Terraform creates a
#   role + instance profile granting SSM access and read on the DB secret only.
###############################################################################

locals {
  create_instance_profile = var.instance_profile_name == null
  instance_profile_name   = local.create_instance_profile ? aws_iam_instance_profile.web[0].name : var.instance_profile_name
}

data "aws_iam_policy_document" "assume" {
  count = local.create_instance_profile ? 1 : 0

  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "web" {
  count              = local.create_instance_profile ? 1 : 0
  name               = "${var.env_name}-web-role"
  assume_role_policy = data.aws_iam_policy_document.assume[0].json

  tags = { Name = "${var.env_name}-web-role" }
}

# Keyless shell access via SSM Session Manager.
resource "aws_iam_role_policy_attachment" "ssm" {
  count      = local.create_instance_profile ? 1 : 0
  role       = aws_iam_role.web[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Read-only access scoped to the DB credentials secret only.
data "aws_iam_policy_document" "secret_read" {
  count = local.create_instance_profile ? 1 : 0

  statement {
    actions   = ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret"]
    resources = [var.secret_arn]
  }
}

resource "aws_iam_role_policy" "secret_read" {
  count  = local.create_instance_profile ? 1 : 0
  name   = "${var.env_name}-secret-read"
  role   = aws_iam_role.web[0].id
  policy = data.aws_iam_policy_document.secret_read[0].json
}

resource "aws_iam_instance_profile" "web" {
  count = local.create_instance_profile ? 1 : 0
  name  = "${var.env_name}-web-profile"
  role  = aws_iam_role.web[0].name

  tags = { Name = "${var.env_name}-web-profile" }
}

###############################################################################
# Launch Template
###############################################################################

resource "aws_launch_template" "web" {
  name_prefix   = "${var.env_name}-web-"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = var.enable_ssh ? aws_key_pair.web[0].key_name : null

  vpc_security_group_ids = [aws_security_group.web.id]

  iam_instance_profile {
    name = local.instance_profile_name
  }

  user_data = base64encode(templatefile("${path.module}/templates/userdata.sh.tftpl", {
    secret_name = var.secret_name
    aws_region  = var.aws_region
    db_init_sql = var.db_init_sql
  }))

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.env_name}-web-asg"
    }
  }

  tags = { Name = "${var.env_name}-web-lt" }
}

###############################################################################
# Auto Scaling Group
###############################################################################

resource "aws_autoscaling_group" "web" {
  name                = "${var.env_name}-web-asg"
  min_size            = var.asg_min
  max_size            = var.asg_max
  desired_capacity    = var.asg_desired
  vpc_zone_identifier = var.subnet_ids
  target_group_arns   = [var.target_group_arn]

  launch_template {
    id = aws_launch_template.web.id
    # Reference the concrete latest version (not "$Latest") so each launch
    # template change bumps this attribute, marks the ASG as changed, and
    # triggers the instance_refresh below on `terraform apply`.
    version = aws_launch_template.web.latest_version
  }

  # Roll instances automatically when the launch template changes (key,
  # IAM profile, userdata, AMI, ...) so `terraform apply` recycles the fleet
  # instead of leaving stale instances running the old template.
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
      instance_warmup        = 120
    }
  }

  tag {
    key                 = "Name"
    value               = "${var.env_name}-web-asg"
    propagate_at_launch = true
  }
}

###############################################################################
# Target Tracking Scaling Policy — CPU 50%
###############################################################################

resource "aws_autoscaling_policy" "cpu" {
  name                   = "${var.env_name}-cpu-target-tracking"
  autoscaling_group_name = aws_autoscaling_group.web.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 50.0
  }
}
