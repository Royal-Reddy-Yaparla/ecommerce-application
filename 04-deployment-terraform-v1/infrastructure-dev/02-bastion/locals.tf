locals {
  subnet_id          = split(",", data.aws_ssm_parameter.public_subnet_id.value)[0]
  security_group_ids = [data.aws_ssm_parameter.bastion_sg_id.value]

}