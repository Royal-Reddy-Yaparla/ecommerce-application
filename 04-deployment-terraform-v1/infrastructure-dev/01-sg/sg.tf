module "bastion_sg" {
  source         = "../../modules/sg"
  sg_name        = var.bastion_sg_name
  sg_description = var.bastion_sg_description
  vpc_id         = local.vpc_id
  project        = var.project
  environment    = var.environment
}

resource "aws_security_group_rule" "bastion_sg_ingress_rules" {
  type            = "ingress"
  from_port       = 22
  to_port         = 22
  protocol        = "tcp"
  cidr_blocks     = ["0.0.0.0/0"]
  security_group_id = local.bastion_sg_id
}

resource "aws_security_group_rule" "bastion_sg_egress_rules" {
  type            = "egress"
  from_port       = 0
  to_port         = 0
  protocol        = "-1"
  cidr_blocks     = ["0.0.0.0/0"]
  security_group_id = local.bastion_sg_id
}