resource "aws_ssm_parameter" "vpc_id" {
  name  = "/${var.project}/${var.environment}/bastion_sg_id"
  type  = "String"
  value = local.bastion_sg_id
}