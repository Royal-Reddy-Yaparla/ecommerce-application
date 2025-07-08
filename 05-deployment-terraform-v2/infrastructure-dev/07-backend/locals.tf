locals {
  vpc_id             = data.aws_ssm_parameter.vpc.value
  subnet_id          = split(",", data.aws_ssm_parameter.private_subnets.value)[0]
  private_subnet_ids = split(",", data.aws_ssm_parameter.private_subnets.value)
  # sg_id    = data.aws_ssm_parameter.sg_id[each.key].value
  common_tags = {
    Project     = var.project
    Environment = var.environment
    Terraform   = true
  }
}