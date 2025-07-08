locals {
  sg_id    = [data.aws_ssm_parameter.sg_id.value]
  common_tags = {
    Project     = var.project
    Environment = var.environment
    Terraform   = true
  }
}