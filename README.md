# Student Records POC — Infrastructure

Terraform IaC project for deploying a student records web application on AWS.

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.0
- AWS CLI profile configured (`~/.aws/credentials`)
- Set `aws_profile` in `src/terraform.tfvars`

## Usage

All commands are run from the `src/` directory.

```bash
cd src
```

### 1. Initialize

Download Terraform providers and modules. Run once initially or whenever modules change.

```bash
terraform init
```

### 2. Plan (preview changes)

Review which resources will be created, changed, or destroyed before applying.

```bash
terraform plan
```

### 3. Apply (create resources)

Apply the planned changes to AWS.

```bash
terraform apply
```

Auto-approve (skip confirmation prompt):

```bash
terraform apply -auto-approve
```

### 4. Destroy (tear down all resources)

Delete all AWS resources managed by Terraform.

```bash
terraform destroy
```

Auto-approve:

```bash
terraform destroy -auto-approve
```

### 5. Check state

List resources currently managed by Terraform:

```bash
terraform state list
```

## Project Structure

```
src/
├── main.tf              # Root module — wires all child modules together
├── variables.tf         # Root variable definitions
├── outputs.tf           # Root outputs
├── providers.tf         # AWS provider configuration
├── backend.tf           # State file backend configuration
├── terraform.tfvars     # Environment-specific variable values (not tracked by git)
└── modules/
    ├── network/         # VPC, subnets, IGW, route tables
    ├── compute/         # EC2 instances, web security group
    ├── loadbalancer/    # ALB, target group, listener, ALB security group
    ├── secrets/         # Secrets Manager for DB credentials
    └── database/        # Aurora MySQL cluster (writer + reader)
```
