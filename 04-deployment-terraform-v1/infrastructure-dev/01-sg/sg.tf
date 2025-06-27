# bastion
module "bastion" {
  source         = "../../modules/sg"
  sg_name        = var.bastion_sg_name
  sg_description = var.bastion_sg_description
  vpc_id         = local.vpc_id
  project        = var.project
  environment    = var.environment
}

# allowing ssh from all
resource "aws_security_group_rule" "bastion_sg_ingress_rules" {
  type            = "ingress"
  from_port       = 22
  to_port         = 22
  protocol        = "tcp"
  cidr_blocks     = ["0.0.0.0/0"]
  security_group_id = module.bastion.sg_id
}

resource "aws_security_group_rule" "bastion_sg_egress_rules" {
  type            = "egress"
  from_port       = 0
  to_port         = 0
  protocol        = "-1"
  cidr_blocks     = ["0.0.0.0/0"]
  security_group_id = module.bastion.sg_id
}

/* 
backend-alb-security-group
allow port 80 from bastion-security-group instead of elastic ip assigning to bastion-ip , ip is dynamic,
we can simple attach bastion-security-group , even bastion ip change , but won't secuity-group change.
*/

# backend-ALB
module "backend_alb" {
  source         = "../../modules/sg"
  sg_name        = var.backend_alb_sg_name
  sg_description = var.backend_alb_description
  vpc_id         = local.vpc_id
  project        = var.project
  environment    = var.environment
}

# allowing http from bastion-sg
resource "aws_security_group_rule" "backend_alb_bastion_ingress_rules" {
  type            = "ingress"
  from_port       = 80
  to_port         = 80
  protocol        = "tcp"
  source_security_group_id     = module.bastion.sg_id
  security_group_id = module.backend_alb.sg_id
}

# allowing http from vpn-sg
resource "aws_security_group_rule" "backend_alb_vpn_ingress_rules" {
  type            = "ingress"
  from_port       = 80
  to_port         = 80
  protocol        = "tcp"
  depends_on = [ module.vpn.sg_id ]
  source_security_group_id     = module.vpn.sg_id
  security_group_id = module.backend_alb.sg_id
}

resource "aws_security_group_rule" "backend_alb_egress_rules" {
  type            = "egress"
  from_port       = 0
  to_port         = 0
  protocol        = "-1"
  cidr_blocks     = ["0.0.0.0/0"]
  security_group_id = module.backend_alb.sg_id
}


# vpn
module "vpn" {
  source         = "../../modules/sg"
  sg_name        = var.vpn_sg_name
  sg_description = var.vpn_sg_description
  vpc_id         = local.vpc_id
  project        = var.project
  environment    = var.environment
}

# allowing ssh,https, 1193,943
resource "aws_security_group_rule" "vpn_ingress_rules" {
  count = length(var.vpn_ports)
  type            = "ingress"
  from_port       = var.vpn_ports[count.index]
  to_port         = var.vpn_ports[count.index]
  protocol        = "tcp"
  cidr_blocks     = ["0.0.0.0/0"]
  security_group_id = module.vpn.sg_id
}

resource "aws_security_group_rule" "vpn_egress_rules" {
  type            = "egress"
  from_port       = 0
  to_port         = 0
  protocol        = "-1"
  cidr_blocks     = ["0.0.0.0/0"]
  security_group_id = module.vpn.sg_id
}

# mongodb


# mongodb rules allow ssh and 27017 from vpn sg