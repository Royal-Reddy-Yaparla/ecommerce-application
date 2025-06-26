module "bastion" {
  source             = "../../modules/ec2"
  ami_id             = data.aws_ami.custom_ami.id
  instance_type      = var.instance_type
  security_group_ids = [data.aws_ssm_parameter.bastion_sg_id.value]
  subnet_id          = local.subnet_id[0]
  project            = var.project
  environment        = var.environment
  component          = var.component
}