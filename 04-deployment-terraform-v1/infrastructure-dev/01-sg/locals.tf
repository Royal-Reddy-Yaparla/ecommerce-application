locals {
  vpc_id = data.aws_ssm_parameter.vpc.value
  bastion_sg_id = module.bastion_sg.sg_id
}