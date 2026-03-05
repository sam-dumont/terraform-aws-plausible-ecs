resource "aws_acm_certificate" "plausible" {
  domain_name       = var.domain_name
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "validation" {
  for_each = {
    for validation_option in aws_acm_certificate.plausible.domain_validation_options :
    validation_option.domain_name => {
      name   = validation_option.resource_record_name
      record = validation_option.resource_record_value
      type   = validation_option.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = var.route53_zone
}

resource "aws_acm_certificate_validation" "cert" {
  certificate_arn         = aws_acm_certificate.plausible.arn
  validation_record_fqdns = [for record in aws_route53_record.validation : record.fqdn]
}

resource "aws_lb_listener_certificate" "plausible" {
  listener_arn    = var.lb_listener_arn
  certificate_arn = aws_acm_certificate.plausible.arn
}
