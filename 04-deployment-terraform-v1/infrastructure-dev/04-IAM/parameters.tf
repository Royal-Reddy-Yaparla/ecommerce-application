resource "aws_ssm_parameter" "iam" {
  name  = "/${var.project}/${var.environment}/Ecom-Mysql-Credential-Access"
  type  = "String"
  value = aws_iam_instance_profile.mysql_profile.name
}