module "sg" {
  source      = "git::https://github.com/sai-pillalamarri/terraform-aws-sg.git"
  count       = length(var.sg_names)
  project     = var.project
  environment = var.environment
  sg_name     = replace(var.sg_names[count.index], "_", "-")
  vpc_id      = local.vpc_id

}
