resource "aws_route53_record" "backend_alb" {
  zone_id         = local.hosted_zone_id
  name            = "*.backend-alb-${var.environment}.aslearnings.online"
  type            = "A"
  allow_overwrite = true

  alias {
    name                   = aws_alb.backend_alb.dns_name
    zone_id                = aws_alb.backend_alb.zone_id
    evaluate_target_health = true
  }


}
