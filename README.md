# Student Records POC — Infrastructure

Terraform IaC for a student records web app on AWS (VPC, ALB, Auto Scaling web tier, RDS MySQL, Secrets Manager). Single region: `us-east-1`.

All commands run from `src/`.

## Prerequisites

- Terraform >= 1.6
- AWS CLI profile configured in `~/.aws/credentials`

## Environment Setup

Variables are loaded automatically from `terraform.tfvars` (gitignored). Copy the template for your target environment and edit it:

```bash
cd src
cp dev.example.tfvars terraform.tfvars       # personal account
# or: cp academy.example.tfvars terraform.tfvars   # AWS Academy lab
```

| Variable | Description |
|----------|-------------|
| `aws_profile` | AWS CLI profile name (`personal` / `academy`) |
| `aws_region` | Region (default `us-east-1`) |
| `env_name` | Name prefix for all resources (default `dev`) |
| `instance_profile_name` | `LabInstanceProfile` for Academy. Leave unset on a personal account to auto-create an IAM role (SSM + secret read). |
| `enable_ssh` | `true` to generate an SSH key pair and open port 22 |
| `ssh_ingress_cidr` | CIDR allowed to SSH. Set to `YOUR_IP/32`. |

## Terraform Usage

```bash
terraform init          # once, or when modules/providers change
terraform plan          # preview changes
terraform apply         # create/update (no -var needed — uses terraform.tfvars)
terraform destroy       # tear down
```

After apply, get the app URL:

```bash
terraform output -raw alb_dns_name      # open http://<that-dns> in a browser
```

## Web Server Access (SSH)

Requires `enable_ssh = true`. The private key is written to `src/<env_name>-web-key.pem`.

```bash
# 1. Find a running instance's public IP (instances are behind an ASG, so IPs change)
aws ec2 describe-instances --profile <profile> --region us-east-1 \
  --filters "Name=instance-state-name,Values=running" "Name=key-name,Values=<env_name>-web-key" \
  --query "Reservations[].Instances[].PublicIpAddress" --output text

# 2. SSH in (user is 'ubuntu')
ssh -i src/<env_name>-web-key.pem ubuntu@<public-ip>
```

## Database

The web tier reads DB credentials from Secrets Manager at boot. To connect from a web instance, use the bundled helper (pulls credentials live from Secrets Manager):

```bash
db-connect                                # interactive mysql session
db-connect -e "SELECT * FROM students;"   # one-off query
```

### DB Init

`init-db.sql` is uploaded to each instance at `/home/ubuntu/init-db.sql`. The schema lives in RDS (shared by all instances), so run it **once from any single instance**:

```bash
db-connect < /home/ubuntu/init-db.sql
```

The script is idempotent (`CREATE TABLE IF NOT EXISTS`), so re-running is safe.

## Project Structure

```
src/
├── main.tf / variables.tf / outputs.tf / versions.tf / providers.tf
├── *.example.tfvars       # per-environment templates (terraform.tfvars is gitignored)
└── modules/
    ├── network/           # VPC, subnets, IGW, route tables
    ├── compute/           # launch template, ASG, web SG, SSH key, IAM profile
    ├── loadbalancer/      # ALB, target group, listener, ALB SG
    ├── secrets/           # Secrets Manager (DB credentials, name "Mydbsecret")
    └── database/          # RDS MySQL, DB SG, subnet group
```
