resource "aws_route53_record" "catalogue" {

  zone_id         = local.zone_id
  name            = "catalogue.backend-alb-dev.aslearnings.online"
  type            = "A"
  ttl             = "1"
  records         = [aws_instance.catalogue.private_ip]
  allow_overwrite = true

}
