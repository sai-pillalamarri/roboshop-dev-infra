module "sg" {
  source      = "git::https://github.com/sai-pillalamarri/terraform-aws-sg.git"
  count       = length(var.sg_names)
  project     = var.project
  environment = var.environment
  sg_name     = var.sg_names[count.index]
  vpc_id      = local.vpc_id

}
