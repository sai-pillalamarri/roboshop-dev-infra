locals {
  common_name = "${var.project}-${var.environment}"
  common_tags = {
    Project     = "var.project"
    Environment = "var.environment"
    Terraform   = "true"
  }

  private_subnet_id = split(",", data.aws_ssm_parameter.private_subnet_ids.value)[0]
  catalogue_sg_id   = data.aws_ssm_parameter.catalouge_sg_id.value
  ami_id            = data.aws_ami.image.id
  zone_id           = data.aws_route53_zone.aslearnings.zone_id
  vpc_id            = data.aws_ssm_parameter.vpc_id.value
  domain_name       = "aslearnings.online"
  backend_alb_arn   = data.aws_ssm_parameter.backend_alb_arn.value
}
