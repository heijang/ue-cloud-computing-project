# ─────────────────────────────────────────────────────────────
# Personal AWS account
# Usage:  cp dev.example.tfvars terraform.tfvars   (then edit your IP)
# After that, `terraform apply` picks it up automatically — no -var needed.
# ─────────────────────────────────────────────────────────────

aws_profile = "personal"
aws_region  = "us-east-1"
env_name    = "dev"

# Leave instance_profile_name unset → Terraform creates the IAM role +
# instance profile (SSM access + read on the DB secret) for you.
# instance_profile_name = null

# SSH access for inspection
enable_ssh       = true
ssh_ingress_cidr = "0.0.0.0/0" # <-- replace with YOUR_PUBLIC_IP/32
