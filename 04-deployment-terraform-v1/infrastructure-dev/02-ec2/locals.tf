locals {
  subnet_id = split(",", data.aws_ssm_parameter.public_subnet_id.value)
}