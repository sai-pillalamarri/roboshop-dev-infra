# mongodb
resource "aws_instance" "mongodb" {

  ami                    = local.ami_id
  instance_type          = "t3.micro"
  vpc_security_group_ids = [local.mongodb_sg_id]
  subnet_id              = local.database_subnet_id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.common_name}-mongodb"
    }
  )

}

resource "terraform_data" "mongodb" {

  triggers_replace = [
    aws_instance.mongodb.private_ip
  ]

  connection {
    type     = "ssh"
    user     = "ec2-user"
    password = "DevOps321"
    host     = aws_instance.mongodb.private_ip
  }

  provisioner "file" {
    source      = "${path.module}/bootstrap.sh"
    destination = "/tmp/bootstrap.sh"

  }

  provisioner "remote-exec" {

    inline = [
      "sudo chmod +x /tmp/bootstrap.sh",
      "sudo sh /tmp/bootstrap.sh mongodb ${var.environment}"
    ]

  }

  depends_on = [aws_instance.mongodb]
}

# redis

resource "aws_instance" "redis" {

  ami                    = local.ami_id
  instance_type          = "t3.micro"
  subnet_id              = local.database_subnet_id
  vpc_security_group_ids = [local.redis_sg_id]

  tags = merge(
    local.common_tags,
    {
      Name = "${local.common_name}-redis"
    }
  )

}

resource "terraform_data" "redis" {

  triggers_replace = [
    aws_instance.redis.private_ip
  ]

  connection {
    type     = "ssh"
    user     = "ec2-user"
    password = "DevOps321"
    host     = aws_instance.redis.private_ip

  }

  provisioner "file" {
    source      = "${path.module}/bootstrap.sh"
    destination = "/tmp/bootstrap.sh"

  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /tmp/bootstrap.sh",
      "sudo sh /tmp/bootstrap.sh redis ${var.environment}"

    ]

  }
  depends_on = [aws_instance.redis]

}

# rabbitmq

resource "aws_instance" "rabbitmq" {

  ami                    = local.ami_id
  instance_type          = "t3.micro"
  subnet_id              = local.database_subnet_id
  vpc_security_group_ids = [local.rabbitmq_sg_id]

  tags = merge(
    local.common_tags,
    {
      Name = "${local.common_name}-rabbitmq"
    }
  )

}

resource "terraform_data" "rabbitmq" {
  triggers_replace = [
    aws_instance.rabbitmq.private_ip
  ]

  connection {
    type     = "ssh"
    user     = "ec2-user"
    password = "DevOps321"
    host     = aws_instance.rabbitmq.private_ip
  }

  provisioner "file" {

    source      = "${path.module}/bootstrap.sh"
    destination = "/tmp/bootstrap.sh"

  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /tmp/bootstrap.sh",
      "sudo sh /tmp/bootstrap.sh rabbitmq ${var.environment}"
    ]

  }
  depends_on = [aws_instance.rabbitmq]

}

# mysql

resource "aws_instance" "mysql" {

  ami                    = local.ami_id
  instance_type          = "t3.micro"
  subnet_id              = local.database_subnet_id
  vpc_security_group_ids = [local.mysql_sg_id]
  iam_instance_profile   = aws_iam_instance_profile.mysql.name

  tags = merge(
    local.common_tags,
    {
      Name = "${local.common_name}-mysql"
    }
  )

}

resource "terraform_data" "mysql" {

  triggers_replace = [
    aws_instance.mysql.private_ip
  ]

  connection {
    type     = "ssh"
    user     = "ec2-user"
    password = "DevOps321"
    host     = aws_instance.mysql.private_ip
  }
  provisioner "file" {
    source      = "${path.module}/bootstrap.sh"
    destination = "/tmp/bootstrap.sh"

  }

  provisioner "remote-exec" {

    inline = [
      "sudo chmod +x /tmp/bootstrap.sh",
      "sudo sh /tmp/bootstrap.sh mysql ${var.environment}"
    ]

  }

  depends_on = [aws_instance.mysql]

}
