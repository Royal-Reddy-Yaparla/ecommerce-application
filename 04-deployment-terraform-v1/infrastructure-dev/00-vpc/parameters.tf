resource "aws_ssm_parameter" "foo" {
  name  = "/${var.project}/${var.environment}/vpc_id"
  type  = "String"
  value = module.vpc.id
}