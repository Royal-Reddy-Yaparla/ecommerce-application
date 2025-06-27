module "alb" {
  source = "terraform-aws-modules/alb/aws"

  name    = "${var.project}-${var.environment}"
  vpc_id  = local.vpc_id
  subnets = local.private_subnet_ids
  security_groups = local.security_group_ids
  internal =  true
  enable_deletion_protection = false

  tags = merge(
    var.alb_tags,
    local.common_tags,
    {
      Name = "${var.project}-${var.environment}"
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