resource "aws_route53_record" "plausible" {
  zone_id = var.route53_zone
  name    = var.domain_name
  type    = "A"
  alias {
    name                   = var.lb_listener_dns
    zone_id                = var.lb_listener_zone_id
    evaluate_target_health = true
  }
}
