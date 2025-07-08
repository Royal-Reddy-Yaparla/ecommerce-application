resource "aws_lb_target_group" "main" {
  name = "${var.project}-${var.environment}-${var.component}"
  port     = var.port
  protocol = "HTTP" #80
  vpc_id   = var.vpc_id
  deregistration_delay = 120

  health_check {
    healthy_threshold   = 2
    interval            = 5
    unhealthy_threshold = 3
    timeout             = 2 # with in 2sec to get response
    port                = var.port
    path                = "/health"
    matcher             = "200-299"
  }
}


resource "aws_instance" "main" {
  ami                    = data.aws_ami.custom_ami.id
  instance_type          = var.instance_type
  vpc_security_group_ids = local.sg_id #
  subnet_id              = var.subnet_id

  tags = merge(
    var.ec2_tags,
    local.common_tags,
    {
      Name = "${var.project}-${var.environment}-${var.component}"
    }
  )
}

# null resources 
resource "terraform_data" "main" {
  triggers_replace = [aws_instance.main.id]

  provisioner "file" {
    source      = "scripts/bootstrap.sh"
    destination = "/tmp/${var.component}.sh"
  }

  connection {
    type     = "ssh"
    user     = "ec2-user"
    password = "DevOps321"
    host     = aws_instance.main.private_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /tmp/${var.component}.sh",
      "sudo sh /tmp/${var.component}.sh ${var.component} ${var.environment}"
    ]
  }
}

# stop instance
resource "aws_ec2_instance_state" "main" {
  instance_id = aws_instance.main.id
  depends_on  = [terraform_data.main]
  state       = "stopped"
}

# take AMI from instance
resource "aws_ami_from_instance" "main" {
  name = "${var.project}-${var.environment}-${var.component}"

  depends_on         = [aws_ec2_instance_state.main]
  source_instance_id = aws_ec2_instance_state.main.id

  tags = merge(
    var.ec2_tags,
    local.common_tags,
    {
      Name = "${var.project}-${var.environment}-${var.component}"
    }
  )
}

# terminate instance 
# null resources 
resource "terraform_data" "main_terminate" {
  triggers_replace = [aws_ec2_instance_state.main.id]
  depends_on       = [aws_ami_from_instance.main]

  provisioner "local-exec" {
    command = "aws ec2 terminate-instances --instance-ids ${aws_ec2_instance_state.main.id}"
  }
}

# launch template
resource "aws_launch_template" "main" {
  name = "${var.project}-${var.environment}-${var.component}"

  image_id               = aws_ami_from_instance.main.id
  instance_type          = var.instance_type
  vpc_security_group_ids = local.sg_id#

  # when traffic getting low , should be turn off , not just stopped 
  instance_initiated_shutdown_behavior = "terminate"

  #each time we update , new version will become default version
  update_default_version = true

  # ec2-tags
  tag_specifications {
    resource_type = "instance"

    tags = merge(
      local.common_tags,
      {
        Name = "${var.project}-${var.environment}-${var.component}"
      }
    )
  }
  # volume-tags
  tag_specifications {
    resource_type = "volume"

    tags = merge(
      local.common_tags,
      {
        Name = "${var.project}-${var.environment}-${var.component}"
      }
    )
  }

  # launch template tags
  tags = merge(
    local.common_tags,
    {
      Name = "${var.project}-${var.environment}-${var.component}"
    }
  )
}

# auto-scaling 
resource "aws_autoscaling_group" "main" {
  name = "${var.project}-${var.environment}-${var.component}"

  desired_capacity = 1
  max_size         = 10
  min_size         = 1

  # checking health of ELB  
  health_check_grace_period = 90 # grace period to check health after launch
  health_check_type         = "ELB"

  vpc_zone_identifier = var.vpc_zone_identifier

  # push new instances those created in auto-scaling to target group
  target_group_arns = [aws_lb_target_group.main.arn]

  # take latest version of launch template
  launch_template {
    id      = aws_launch_template.main.id
    version = aws_launch_template.main.latest_version
  }

  # while updating old version instance down bring new version up
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
    triggers = ["launch_template"]
  }

  timeouts {
    delete = "15m"
  }

  dynamic "tag" {
    for_each = merge(
      local.common_tags,
      {
        Name = "${var.project}-${var.environment}-${var.component}"
      }
    )
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}


resource "aws_autoscaling_policy" "main" {
  name                   = "${var.project}-${var.environment}-${var.component}"
  autoscaling_group_name = aws_autoscaling_group.main.name
  policy_type            = "TargetTrackingScaling"
  # cooldown               = 120 # after launch 2ait for 120 sec to collect metrics
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 75.0
  }
}

# host_based_weighted_routing
resource "aws_lb_listener_rule" "main" {
  listener_arn = var.alb_listener_arn
  priority     = var.priority
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }

  condition {
    host_header {
      values = ["${var.component}.backend-${var.environment}.${var.domain}"]
    }
  }
}