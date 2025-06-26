module "bastion" {
  source             = "../../modules/ec2"
  ami_id             = data.aws_ami.custom_ami.id
  instance_type      = var.instance_type
  security_group_ids = local.security_group_ids
  subnet_id          = local.subnet_id
  project            = var.project
  environment        = var.environment
  component          = var.component
}