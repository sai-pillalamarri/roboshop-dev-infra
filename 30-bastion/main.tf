resource "aws_instance" "bastion" {

  ami                    = local.ami_id
  instance_type          = "t3.micro"
  subnet_id              = local.public_subnet_id
  vpc_security_group_ids = [local.bastion_sg_id]

  root_block_device {
    volume_size = 50
    volume_type = "gp3"

    tags = merge(
      {
        Name = "${local.common_name}-bastion"
      },
      local.common_tags
    )
  }

  user_data = templatefile("${path.module}/bastion.sh.tftpl", {
    partition_number = 4
    extend_size      = 30
  })

  tags = merge(
    {
      Name = "${local.common_name}-bastion"
    },
    local.common_tags
  )

}
