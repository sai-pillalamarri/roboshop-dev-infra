resource "aws_route53_record" "mongodb" {

  zone_id         = local.hosted_zone_id
  name            = "mongodb.${var.environment}.${local.domain_name}"
  ttl             = "1"
  type            = "A"
  records         = [aws_instance.mongodb.private_ip]
  allow_overwrite = true

}

resource "aws_route53_record" "redis" {

  zone_id         = local.hosted_zone_id
  name            = "redis.${var.environment}.${local.domain_name}"
  ttl             = "1"
  type            = "A"
  records         = [aws_instance.redis.private_ip]
  allow_overwrite = true

}

resource "aws_route53_record" "rabbitmq" {

  zone_id         = local.hosted_zone_id
  name            = "rabbitmq.${var.environment}.${local.domain_name}"
  ttl             = "1"
  type            = "A"
  records         = [aws_instance.rabbitmq.private_ip]
  allow_overwrite = true

}

resource "aws_route53_record" "mysql" {

  zone_id         = local.hosted_zone_id
  name            = "mysql.${var.environment}.${local.domain_name}"
  ttl             = "1"
  type            = "A"
  records         = [aws_instance.mysql.private_ip]
  allow_overwrite = true

}
