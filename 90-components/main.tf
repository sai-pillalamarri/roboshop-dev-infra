module "components" {

  for_each      = var.components
  source        = "git::https://github.com/sai-pillalamarri/terraform-roboshop-component.git?ref=main"
  component     = each.key
  rule_priority = each.value.rule_priority
  app_version   = each.value.app_version
  environment   = var.environment

}
