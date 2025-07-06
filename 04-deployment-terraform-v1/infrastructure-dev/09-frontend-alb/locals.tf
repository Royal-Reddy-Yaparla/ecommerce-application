locals {
  vpc_id             = data.aws_ssm_parameter.vpc.value
  public_subnet_ids  = split(",", data.aws_ssm_parameter.public_subnet_ids.value)
  security_group_ids = ["${data.aws_ssm_parameter.frontend_alb_sg_id.value}"]
  common_tags = {
    Project     = var.project
    Environment = var.environment
    Terraform   = true
  }
}