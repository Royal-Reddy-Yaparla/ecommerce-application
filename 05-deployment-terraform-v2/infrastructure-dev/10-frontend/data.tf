data "aws_ami" "custom_ami" {
  owners      = ["973714476881"]
  most_recent = true
  filter {
    name   = "name"
    values = ["RHEL-9-DevOps-Practice"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

data "aws_ssm_parameter" "frontend_sg_id" {
  name = "/${var.project}/${var.environment}/frontend_sg_id"
}

data "aws_ssm_parameter" "vpc" {
  name = "/${var.project}/${var.environment}/vpc_id"
}

data "aws_ssm_parameter" "public_subnets" {
  name = "/${var.project}/${var.environment}/public_subnets"
}

data "aws_ssm_parameter" "frontend_alb_listener_arn" {
  name = "/${var.project}/${var.environment}/frontend_alb_listener_arn"
}
