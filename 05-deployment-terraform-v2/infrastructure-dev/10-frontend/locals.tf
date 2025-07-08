locals {
  vpc_id            = data.aws_ssm_parameter.vpc.value
  subnet_id         = split(",", data.aws_ssm_parameter.public_subnets.value)[0]
  public_subnet_ids = split(",", data.aws_ssm_parameter.public_subnets.value)
  frontend_sg_id    = [data.aws_ssm_parameter.frontend_sg_id.value]
  common_tags = {
    Project     = var.project
    Environment = var.environment
    Terraform   = true
  }
}