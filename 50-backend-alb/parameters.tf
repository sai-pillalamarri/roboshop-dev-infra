resource "aws_ssm_parameter" "backend_alb_arn" {
  name      = "/${var.project}/${var.environment}/backend_alb_arn"
  type      = string
  value     = aws_alb.backend_alb.arn
  overwrite = true

}
