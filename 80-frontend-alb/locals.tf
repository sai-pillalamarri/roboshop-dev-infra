locals {
  frontend_alb_sg_id = data.aws_ssm_parameter.frontend_alb_sg_id.value
  public_subnet_id   = split(",", data.aws_ssm_parameter.public_subnet_ids.value)
  common_name        = "${var.project}-${var.environment}"
  common_tags = {
    Project     = var.project
    Environment = var.environment
    Terraform   = "true"
  }
  acm_arn = data.aws_ssm_parameter.acm_arn.value
  zone_id = data.aws_route53_zone.aslearnings.zone_id
}
