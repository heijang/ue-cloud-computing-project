provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile

  default_tags {
    tags = {
      Project   = "student-records-poc"
      ManagedBy = "terraform"
      Env       = var.env_name
    }
  }
}
