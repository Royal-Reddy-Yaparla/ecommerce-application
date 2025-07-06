# bastion
module "bastion" {
  source         = "../../modules/sg"
  sg_name        = "bastion"
  sg_description = "allowing SSH,HTTP,HTTPS"
  vpc_id         = local.vpc_id
  project        = var.project
  environment    = var.environment
}

# allowing ssh from all
resource "aws_security_group_rule" "bastion_sg_ingress_rules" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.bastion.sg_id
}

resource "aws_security_group_rule" "bastion_sg_egress_rules" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
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
  sg_name        = "backend_alb"
  sg_description = "allowing SSH"
  vpc_id         = local.vpc_id
  project        = var.project
  environment    = var.environment
}

# allowing http from bastion-sg
resource "aws_security_group_rule" "backend_alb_bastion_ingress_rules" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = module.bastion.sg_id
  security_group_id        = module.backend_alb.sg_id
}

# allowing http from vpn-sg
resource "aws_security_group_rule" "backend_alb_vpn_ingress_rules" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  depends_on               = [module.vpn.sg_id]
  source_security_group_id = module.vpn.sg_id
  security_group_id        = module.backend_alb.sg_id
}

resource "aws_security_group_rule" "backend_alb_egress_rules" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.backend_alb.sg_id
}


# vpn
module "vpn" {
  source         = "../../modules/sg"
  sg_name        = "vpn"
  sg_description = "allowing SSH HTTPS 1193 943"
  vpc_id         = local.vpc_id
  project        = var.project
  environment    = var.environment
}

# allowing ssh,https, 1194,943
resource "aws_security_group_rule" "vpn_ingress_rules" {
  count             = length(var.vpn_ports)
  type              = "ingress"
  from_port         = var.vpn_ports[count.index]
  to_port           = var.vpn_ports[count.index]
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.vpn.sg_id
}

resource "aws_security_group_rule" "vpn_egress_rules" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.vpn.sg_id
}

# mongodb
module "mongodb" {
  source         = "../../modules/sg"
  sg_name        = "mongodb"
  sg_description = "allowing SSH 27017"
  vpc_id         = local.vpc_id
  project        = var.project
  environment    = var.environment
}

# mongodb rules allow ssh and 27017 from vpn sg
resource "aws_security_group_rule" "mongodb_ingress_rules" {
  count             = length(var.mongodb_ports)
  type              = "ingress"
  from_port         = var.mongodb_ports[count.index]
  to_port           = var.mongodb_ports[count.index]
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.mongodb.sg_id
}

# mongodb egress
resource "aws_security_group_rule" "mongodb_egress_rules" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.mongodb.sg_id
}

# mysql 
module "mysql" {
  source         = "../../modules/sg"
  sg_name        = "mysql"
  sg_description = "allowing SSH 3306"
  vpc_id         = local.vpc_id
  project        = var.project
  environment    = var.environment
}

# mysql rules allow ssh and 3306 from vpn sg
resource "aws_security_group_rule" "mysql_ingress_rules" {
  count             = length(var.mysql_ports)
  type              = "ingress"
  from_port         = var.mysql_ports[count.index]
  to_port           = var.mysql_ports[count.index]
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.mysql.sg_id
}

# mysql egress
resource "aws_security_group_rule" "mysql_egress_rules" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.mysql.sg_id
}

# redis 
module "redis" {
  source         = "../../modules/sg"
  sg_name        = "redis"
  sg_description = "allowing SSH 6379"
  vpc_id         = local.vpc_id
  project        = var.project
  environment    = var.environment
}

# redis rules allow ssh and 6379 from vpn sg
resource "aws_security_group_rule" "redis_ingress_rules" {
  count             = length(var.redis_ports)
  type              = "ingress"
  from_port         = var.redis_ports[count.index]
  to_port           = var.redis_ports[count.index]
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.redis.sg_id
}

# redis egress
resource "aws_security_group_rule" "redis_egress_rules" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.redis.sg_id
}


# rabbitmq 
module "rabbitmq" {
  source         = "../../modules/sg"
  sg_name        = "rabbitmq"
  sg_description = "allowing SSH 5672"
  vpc_id         = local.vpc_id
  project        = var.project
  environment    = var.environment
}

# rabbitmq rules allow ssh and 5672 from vpn sg
resource "aws_security_group_rule" "rabbitmq_ingress_rules" {
  count             = length(var.rabbitmq_ports)
  type              = "ingress"
  from_port         = var.rabbitmq_ports[count.index]
  to_port           = var.rabbitmq_ports[count.index]
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.rabbitmq.sg_id
}

# redis egress
resource "aws_security_group_rule" "rabbitmq_egress_rules" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.rabbitmq.sg_id
}

# catalogue
module "catalogue" {
  source         = "../../modules/sg"
  sg_name        = "catalogue"
  sg_description = "allowing SSH 8080"
  vpc_id         = local.vpc_id
  project        = var.project
  environment    = var.environment
}

# catalogue rules allow ssh and 8080 from bastion sg
resource "aws_security_group_rule" "catalogue_bastion_ingress_rules" {
  count                    = length(var.catalogue_ports)
  type                     = "ingress"
  from_port                = var.catalogue_ports[count.index]
  to_port                  = var.catalogue_ports[count.index]
  protocol                 = "tcp"
  source_security_group_id = module.bastion.sg_id
  security_group_id        = module.catalogue.sg_id
}

# catalogue rules allow ssh and 8080 from vpn sg
resource "aws_security_group_rule" "catalogue_vpn_ingress_rules" {
  count                    = length(var.catalogue_ports)
  type                     = "ingress"
  from_port                = var.catalogue_ports[count.index]
  to_port                  = var.catalogue_ports[count.index]
  protocol                 = "tcp"
  source_security_group_id = module.vpn.sg_id
  security_group_id        = module.catalogue.sg_id
}

# catalogue rules allow ssh and 8080 from backend-alb sg
resource "aws_security_group_rule" "catalogue_backend_alb_ingress_rules" {
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = module.backend_alb.sg_id
  security_group_id        = module.catalogue.sg_id
}


# catalogue egress
resource "aws_security_group_rule" "catalogue_egress_rules" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.catalogue.sg_id
}

# mongodb rules allow ssh and 27017 from catalogue sg
resource "aws_security_group_rule" "mongodb_catalogue_ingress_rules" {
  type                     = "ingress"
  from_port                = 27017
  to_port                  = 27017
  protocol                 = "tcp"
  source_security_group_id = module.catalogue.sg_id
  security_group_id        = module.mongodb.sg_id
}

# frontend alb
module "frontend_alb" {
  source         = "../../modules/sg"
  sg_name        = "frontend_alb"
  sg_description = "allowing HTTP and HTTPS"
  vpc_id         = local.vpc_id
  project        = var.project
  environment    = var.environment
}

# allowing http from 0.0.0.0/0
resource "aws_security_group_rule" "frontend_alb_http_ingress_rule" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.frontend_alb.sg_id
}

# allowing https from 0.0.0.0/0
resource "aws_security_group_rule" "frontend_alb_https_ingress_rule" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.frontend_alb.sg_id
}

resource "aws_security_group_rule" "frontend_alb_egress_rules" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.frontend_alb.sg_id
}

# frontend
module "frontend" {
  source         = "../../modules/sg"
  sg_name        = "frontend"
  sg_description = "allowing SSH,HTTP and HTTPS"
  vpc_id         = local.vpc_id
  project        = var.project
  environment    = var.environment
}

# frontend ingress
resource "aws_security_group_rule" "frontend_frontend_alb_ingress_rules" {
  count                    = length(var.frontend_ports)
  type                     = "ingress"
  from_port                = var.frontend_ports[count.index]
  to_port                  = var.frontend_ports[count.index]
  protocol                 = "tcp"
  source_security_group_id = module.frontend_alb.sg_id
  security_group_id        = module.frontend.sg_id
}

# frontend egress
resource "aws_security_group_rule" "frontend_egress_rules" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.frontend.sg_id
}