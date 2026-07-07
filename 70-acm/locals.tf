locals {
  zone_id     = data.aws_route53_zone.aslearnings.zone_id
  domain      = "aslearnings.online"
  common_name = "${var.project}-${var.environment}"
  common_tags = {
    Project     = var.project
    Environment = var.environment
    Terraform   = "true"
  }
}
