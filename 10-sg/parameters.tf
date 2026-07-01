resource "aws_ssm_parameter" "sg_ids" {
  count     = length(var.sg_names)
  name      = "/${var.project}/${var.environment}/${var.sg_names[count.index]}/sg_id"
  type      = "String"
  value     = module.sg[count.index].sg_id
  overwrite = true

}
