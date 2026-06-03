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
# EC2 Instances (one per AZ, public subnet)
###############################################################################

resource "aws_instance" "web" {
  count = var.az_count

  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_ids[count.index]
  vpc_security_group_ids = [aws_security_group.web.id]
  iam_instance_profile   = var.instance_profile_name

  user_data = <<-USERDATA
    #!/bin/bash
    cat > /opt/server.py << 'PYEOF'
    #!/usr/bin/env python3
    import http.server, socket

    class Handler(http.server.BaseHTTPRequestHandler):
        def do_GET(self):
            host = socket.gethostname()
            ip = socket.gethostbyname(host)
            self.send_response(200)
            self.send_header("Content-Type", "text/html")
            self.end_headers()
            self.wfile.write(f"<h1>Hello from {host}</h1><p>IP: {ip}</p>".encode())

    http.server.HTTPServer(("", 80), Handler).serve_forever()
    PYEOF
    chmod +x /opt/server.py
    nohup python3 /opt/server.py &
  USERDATA

  tags = { Name = "${var.env_name}-web-${count.index + 1}" }
}
