locals {

  common_name = "${var.project}-${var.environment}"
  common_tags = {
    Name        = local.common_name
    Project     = var.project
    Environment = var.environment
    Terraform   = "true"
  }

  ami_id             = data.aws_ami.practice_image.id
  vpc_id             = data.aws_ssm_parameter.vpc_id.value
  database_subnet_id = split(",", data.aws_ssm_parameter.database_subnet_ids.value)[0]
  hosted_zone_id     = data.aws_route53_zone.hosted_zone.zone_id
  domain_name        = "aslearnings.online"


  mongodb_sg_id  = data.aws_ssm_parameter.mongodb_sg_id.value
  redis_sg_id    = data.aws_ssm_parameter.redis_sg_id.value
  mysql_sg_id    = data.aws_ssm_parameter.mysql_sg_id.value
  rabbitmq_sg_id = data.aws_ssm_parameter.rabbitmq_sg_id.value

}
