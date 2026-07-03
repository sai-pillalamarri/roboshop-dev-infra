resource "aws_alb" "backend_alb" {
  name               = "${local.common_name}-backend-alb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [local.backend_alb_sg_id]
  subnets            = split(",", local.private_subnet_ids)

  enable_deletion_protection = false

  tags = merge(
    local.common_tags,
    {
      Name = "${local.common_name}-backend-alb"
    }
  )

}

resource "aws_alb_listener" "backend_alb" {
  load_balancer_arn = aws_alb.backend_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/html"
      message_body = "<h1> Hi i am from backend alb </h1> "
      status_code  = "200"

    }
  }

}
