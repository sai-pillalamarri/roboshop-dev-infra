resource "aws_alb" "frontend_alb" {

  name               = "${local.common_name}-frontend-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [local.frontend_alb_sg_id]
  subnets            = local.public_subnet_id

  enable_deletion_protection = false

  tags = merge(
    local.common_tags,
    {
      Name = "${local.common_name}-frontend-alb"
    }
  )

}

resource "aws_alb_listener" "frontend_alb" {
  load_balancer_arn = aws_alb.frontend_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = local.acm_arn

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Fixed response content"
      status_code  = "200"
    }
  }

}

resource "aws_route53_record" "frontend_alb" {
  zone_id         = local.zone_id
  name            = "frontend-alb-${var.environment}.aslearnings.online"
  type            = "A"
  allow_overwrite = true

  alias {
    name                   = aws_alb.frontend_alb.dns_name
    zone_id                = aws_alb.frontend_alb.zone_id
    evaluate_target_health = true
  }


}
