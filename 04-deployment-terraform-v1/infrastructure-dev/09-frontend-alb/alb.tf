module "alb" {
  source = "terraform-aws-modules/alb/aws"

  name                       = "${var.project}-${var.environment}-backend-alb"
  vpc_id                     = local.vpc_id
  subnets                    = local.private_subnet_ids
  security_groups            = local.security_group_ids
  internal                   = true
  enable_deletion_protection = false

  tags = merge(
    var.alb_tags,
    local.common_tags,
    {
      Name = "${var.project}-${var.environment}-backend-alb"
    }
  )
}