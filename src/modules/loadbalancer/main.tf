###############################################################################
# ALB Security Group — allows HTTP from anywhere
###############################################################################

resource "aws_security_group" "alb" {
  name        = "${var.env_name}-alb-sg"
  description = "Allow HTTP inbound to ALB"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.env_name}-alb-sg" }
}

###############################################################################
# Application Load Balancer
###############################################################################

resource "aws_lb" "this" {
  name               = "${var.env_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.subnet_ids

  tags = { Name = "${var.env_name}-alb" }
}

###############################################################################
# Target Group — HTTP:80
###############################################################################

resource "aws_lb_target_group" "web" {
  name     = "${var.env_name}-web-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = { Name = "${var.env_name}-web-tg" }
}

###############################################################################
# Target Group Attachment
###############################################################################

resource "aws_lb_target_group_attachment" "web" {
  count = length(var.instance_ids)

  target_group_arn = aws_lb_target_group.web.arn
  target_id        = var.instance_ids[count.index]
  port             = 80
}

###############################################################################
# Listener — HTTP:80 → Target Group
###############################################################################

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }

  tags = { Name = "${var.env_name}-http-listener" }
}
