resource "aws_ssm_parameter" "aws_acm_certificate_arn" {
  name  = "/${var.project}/${var.environment}/aws_acm_certificate_arn"
  type  = "String"
  value = aws_acm_certificate.main.arn
}
