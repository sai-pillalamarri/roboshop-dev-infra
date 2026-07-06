resource "aws_instance" "catalogue" {

  ami                    = local.ami_id
  instance_type          = "t3.micro"
  subnet_id              = local.private_subnet_id
  vpc_security_group_ids = [local.catalogue_sg_id]

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project}-${var.environment}-catalogue"
    }
  )

}

resource "terraform_data" "catalogue" {

  triggers_replace = [
    aws_instance.catalogue.private_ip
  ]

  connection {
    type     = "ssh"
    user     = "ec2-user"
    password = "DevOps321"
    host     = aws_instance.catalogue.private_ip
  }

  provisioner "file" {
    source      = "${path.module}/bootstrap.sh"
    destination = "/tmp/bootstrap.sh"

  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /tmp/bootstrap.sh",
      "sudo sh /tmp/bootstrap.sh catalogue ${var.environment} ${var.app_version}"
    ]

  }

  depends_on = [aws_instance.catalogue]

}

resource "aws_ec2_instance_state" "catalogue" {

  instance_id = aws_instance.catalogue.id
  state       = "stopped"
  depends_on  = [terraform_data.catalogue]

}

resource "aws_ami_from_instance" "catalogue" {

  name               = "${local.common_name}-catalogue-${var.app_version}-${aws_instance.catalogue.id}"
  source_instance_id = aws_instance.catalogue.id
  depends_on         = [aws_ec2_instance_state.catalogue]

  tags = merge(
    local.common_tags,
    {
      Name = "${local.common_name}-catalogue-${var.app_version}-${aws_instance.catalogue.id}"
    }
  )

}

resource "aws_launch_template" "catalogue" {

  name                                 = "${var.project}-${var.environment}-catalogue"
  image_id                             = aws_ami_from_instance.catalogue.id
  instance_type                        = "t3.micro"
  vpc_security_group_ids               = [local.catalogue_sg_id]
  instance_initiated_shutdown_behavior = "terminate"
  update_default_version               = true

  # Oncce the instances are created, these will become instance tags
  tag_specifications {
    resource_type = "instance"

    tags = merge(
      local.common_tags,
      {
        Name = "${var.project}-${var.environment}-catalogue-${var.app_version}-${aws_instance.catalogue.id}"
      }
    )

  }

  # Oncce the instances are created, these will become volume tags
  tag_specifications {
    resource_type = "volume"
    tags = merge(
      local.common_tags,
      {
        Name = "${var.project}-${var.environment}-catalogue-${var.app_version}-${aws_instance.catalogue.id}"
      }
    )
  }

  # Launch template resource tags
  tags = merge(
    local.common_tags,
    {
      Name = "${local.common_name}-catalogue-${var.app_version}-${aws_instance.catalogue.id}"
    }
  )

}


resource "aws_alb_target_group" "catalogue" {
  name     = "${local.common_name}-catalogue"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = local.vpc_id

  health_check {
    healthy_threshold   = 2
    interval            = 10
    matcher             = "200-299"
    path                = "/health"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2


  }

  tags = merge(
    local.common_tags,
    {
      Name = "${local.common_name}-catalogue"
    }
  )

}

resource "aws_autoscaling_group" "catalogue" {

  name                      = "${local.common_name}-catalogue"
  max_size                  = 10
  min_size                  = 1
  health_check_grace_period = 120
  health_check_type         = "ELB"
  desired_capacity          = 2
  force_delete              = false
  target_group_arns         = [aws_alb_target_group.catalogue.arn]
  vpc_zone_identifier       = [local.private_subnet_id]
  launch_template {
    id      = aws_launch_template.catalogue.id
    version = "$Latest"
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
    triggers = ["launch_template"]
  }

  dynamic "tag" {
    for_each = merge(
      {
        Name = "${local.common_name}-catalogue"
      },
      local.common_tags
    )

    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }

  }

  # with in 15min autoscaling should be successful to launch instances
  timeouts {
    delete = "15m"
  }

}

resource "aws_autoscaling_policy" "catalogue" {
  name                      = "${local.common_name}-catalogue"
  autoscaling_group_name    = aws_autoscaling_group.catalogue.name
  policy_type               = "TargetTrackingScaling"
  estimated_instance_warmup = 120
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 75.0
  }

}

resource "aws_alb_listener_rule" "catalogue" {
  listener_arn = local.backend_alb_arn
  priority     = 10
  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.catalogue.arn
  }
  condition {
    host_header {
      values = ["catalogue.backend-alb-${var.environment}.${local.domain_name}"]
    }
  }

}

resource "terraform_data" "catalogue_terminate" {

  triggers_replace = [
    aws_instance.catalogue.id
  ]

  # executes where terraform is running
  provisioner "local-exec" {
    command = "aws ec2 terminate-instances --instance-ids ${aws_instance.catalogue.id}"

  }

  depends_on = [aws_autoscaling_policy.catalogue]

}
