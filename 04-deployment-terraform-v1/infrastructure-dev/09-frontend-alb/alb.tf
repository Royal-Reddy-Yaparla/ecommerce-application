module "alb" {
  source = "terraform-aws-modules/alb/aws"

  name                       = "${var.project}-${var.environment}-frontend-alb"
  vpc_id                     = local.vpc_id
  subnets                    = local.public_subnet_ids
  security_groups            = local.security_group_ids
   internal                   = false
  enable_deletion_protection = false

  tags = merge(
    var.alb_tags,
    local.common_tags,
    {
      Name = "${var.project}-${var.environment}-frontend-alb" # change to frontend
    }
  )
}


resource "aws_lb_listener" "frontend_https" {
  load_balancer_arn = module.alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = local.certificate_arn
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/html"
      message_body = "Hello I am Frontend Load-Balancer"
      status_code  = "200"
    }
  }
}

resource "aws_route53_record" "frontend_alb" {
  zone_id = var.zone_id
  name = "*.${var.environment}.${var.domain}"
  type = "A"
  alias {
    name                   = module.alb.dns_name
    zone_id                = module.alb.zone_id
    evaluate_target_health = true
  }
}
