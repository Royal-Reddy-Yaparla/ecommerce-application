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

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = module.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/html"
      message_body = "Hello I am Backend Load-Balancer"
      status_code  = "200"
    }
  }
}

resource "aws_route53_record" "backend-alb" {
  zone_id = var.zone_id
################################################################################
# backend-dev-royalreddy.site is forwarded to the Application Load Balancer (ALB),
  # which serves as the entry point for multiple backend components.
# Example:
  # - catalogue.backend-dev-royalreddy.site should be routed to the "catalogue" target group.
# To achieve this, we need to create a separate subdomain for each component,
  # like:
  # - catalogue.backend-dev-royalreddy.site
  # - cart.backend-dev-royalreddy.site
  # - user.backend-dev-royalreddy.site
  # and so on.
# A wildcard DNS record (*.backend-dev-royalreddy.site) should be configured
  # to point to the ALB, enabling dynamic subdomain resolution and routing
  # via ALB listener rules based on the Host header.
################################################################################
  name    = "*.backend-${var.environment}.${var.domain}"
  type    = "A"
  alias {
    name                   = module.alb.dns_name
    zone_id                = module.alb.zone_id
    evaluate_target_health = true
  }
}
