# ─────────────────────────────────────────────────────────────
# AWS Academy lab
# Usage:  cp academy.example.tfvars terraform.tfvars   (then edit your IP)
# After that, `terraform apply` picks it up automatically — no -var needed.
# ─────────────────────────────────────────────────────────────

aws_profile = "academy"
aws_region  = "us-east-1"
env_name    = "dev"

# Lab forbids creating IAM roles — reuse the provided instance profile.
instance_profile_name = "LabInstanceProfile"

# SSH access for inspection
enable_ssh       = true
ssh_ingress_cidr = "0.0.0.0/0" # <-- replace with YOUR_PUBLIC_IP/32
