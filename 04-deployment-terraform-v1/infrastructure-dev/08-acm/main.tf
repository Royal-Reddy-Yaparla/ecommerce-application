resource "aws_acm_certificate" "main" {
  domain_name       = "*.royalreddy.site"
  validation_method = "DNS"

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project}-${var.environment}"
    }
  )
  lifecycle {
    create_before_destroy = true
  }
}  


resource "aws_route53_record" "main" {
  allow_overwrite = true
  name =  tolist(aws_acm_certificate.main.domain_validation_options)[0].resource_record_name
  records = [tolist(aws_acm_certificate.main.domain_validation_options)[0].resource_record_value]
  type = tolist(aws_acm_certificate.main.domain_validation_options)[0].resource_record_type
  zone_id = var.zone_id
  ttl = 60
}

resource "aws_acm_certificate_validation" "main" {
  certificate_arn = aws_acm_certificate.main.arn
  validation_record_fqdns = [aws_route53_record.main.fqdn]
}