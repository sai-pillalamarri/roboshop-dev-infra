locals {
  ami_id           = data.aws_ami.practice_image.id
  vpc_id           = data.aws_ssm_parameter.vpc_id.value
  bastion_sg_id    = data.aws_ssm_parameter.bastion_sg_id.value
  public_subnet_id = split(",", data.aws_ssm_parameter.public_subnet_id.value)[0]

  common_name = "${var.project}-${var.environment}"
  common_tags = {
    Project     = var.project
    Environment = var.environment
    Terraform   = true
  }

}
