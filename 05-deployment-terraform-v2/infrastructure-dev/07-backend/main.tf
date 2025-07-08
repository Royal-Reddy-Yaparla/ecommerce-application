module "backend" {
  for_each = { for component in var.components : component.name => component }
  source = "../../modules/component"
  component = each.value.name
  port = 8080
  vpc_id = local.vpc_id
  subnet_id = local.subnet_id
  priority = each.value.priority
  vpc_zone_identifier = local.private_subnet_ids
  alb_listener_arn = data.aws_ssm_parameter.backend_alb_listener_arn.value
}