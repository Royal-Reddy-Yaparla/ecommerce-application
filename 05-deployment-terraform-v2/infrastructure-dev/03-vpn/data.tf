data "aws_ami" "vpn_ami" {
  owners      = ["679593333241"]
  most_recent = true
  filter {
    name   = "name"
    values = ["OpenVPN Access Server Community Image-8fb*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

data "aws_ssm_parameter" "vpn_sg_id" {
  name = "/${var.project}/${var.environment}/vpn_sg_id"
}

data "aws_ssm_parameter" "public_subnet_id" {
  name = "/${var.project}/${var.environment}/public_subnets"
}