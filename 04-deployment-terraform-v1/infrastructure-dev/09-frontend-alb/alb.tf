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

resource "aws_lb_listener" "frontend_http" {
  load_balancer_arn = module.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/html"
      message_body = "Hello I am Frontend Load-Balancer"
      status_code  = "200"
    }
  }
}

# resource "aws_lb_listener" "frontend_https" {
#   load_balancer_arn = module.alb.arn
#   port              = "443"
#   protocol          = "HTTPS"

#   default_action {
#     type = "fixed-response"

#     fixed_response {
#       content_type = "text/html"
#       message_body = "Hello I am Frontend Load-Balancer"
#       status_code  = "200"
#     }
#   }
# }

