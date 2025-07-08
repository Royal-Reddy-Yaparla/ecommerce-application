resource "aws_lb_target_group" "frontend" {
  name     = "${var.project}-${var.environment}-frontend"
  port     = 80
  protocol = "HTTP" #80
  vpc_id   = local.vpc_id
  /* This sets a 120-second delay before the ALB stops sending traffic to a target
  When a target is scheduled for removal (e.g., ASG scale-in or Terraform destroy), 
  wait 120 seconds before stopping traffic to it 
  */
  deregistration_delay = 120

  health_check {
    healthy_threshold   = 2
    interval            = 5
    unhealthy_threshold = 3
    timeout             = 2 # with in 2sec to get response
    port                = 80
    path                = "/"
    matcher             = "200-299"
  }
}

# frontend instance
resource "aws_instance" "frontend" {
  ami                    = data.aws_ami.custom_ami.id
  instance_type          = var.instance_type
  vpc_security_group_ids = local.frontend_sg_id
  subnet_id              = local.subnet_id

  tags = merge(
    var.ec2_tags,
    local.common_tags,
    {
      Name = "${var.project}-${var.environment}-frontend"
    }
  )
}

# null resources 
resource "terraform_data" "frontend" {
  triggers_replace = [aws_instance.frontend.id]

  provisioner "file" {
    source      = "scripts/bootstrap.sh"
    destination = "/tmp/frontend.sh"
  }

  connection {
    type     = "ssh"
    user     = "ec2-user"
    password = "DevOps321"
    host     = aws_instance.frontend.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /tmp/frontend.sh",
      "sudo sh /tmp/frontend.sh frontend dev"
    ]
  }
}

# stop instance
resource "aws_ec2_instance_state" "frontend" {
  instance_id = aws_instance.frontend.id
  depends_on  = [terraform_data.frontend]
  state       = "stopped"
}

# take AMI from instance
resource "aws_ami_from_instance" "frontend" {
  name = "${var.project}-${var.environment}-frontend"

  depends_on         = [aws_ec2_instance_state.frontend]
  source_instance_id = aws_ec2_instance_state.frontend.id

  tags = merge(
    var.ec2_tags,
    local.common_tags,
    {
      Name = "${var.project}-${var.environment}-frontend"
    }
  )
}

# launch template
resource "aws_launch_template" "frontend" {
  name = "${var.project}-${var.environment}-frontend"

  image_id               = aws_ami_from_instance.frontend.id
  instance_type          = var.instance_type
  vpc_security_group_ids = local.frontend_sg_id

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
        Name = "${var.project}-${var.environment}-frontend"
      }
    )
  }
  # volume-tags
  tag_specifications {
    resource_type = "volume"

    tags = merge(
      local.common_tags,
      {
        Name = "${var.project}-${var.environment}-frontend"
      }
    )
  }

  # launch template tags
  tags = merge(
    local.common_tags,
    {
      Name = "${var.project}-${var.environment}-frontend"
    }
  )
}

resource "aws_autoscaling_group" "frontend" {
  name = "${var.project}-${var.environment}-frontend"

  desired_capacity = 1
  max_size         = 10
  min_size         = 1

  # checking health of ELB  
  health_check_grace_period = 90 # grace period to check health after launch
  health_check_type         = "ELB"

  vpc_zone_identifier = local.public_subnet_ids

  # push new instances those created in auto-scaling to target group
  target_group_arns = [aws_lb_target_group.frontend.arn]

  # take latest version of launch template
  launch_template {
    id      = aws_launch_template.frontend.id
    version = aws_launch_template.frontend.latest_version
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
        Name = "${var.project}-${var.environment}-frontend"
      }
    )
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}

resource "aws_autoscaling_policy" "frontend" {
  name                   = "${var.project}-${var.environment}-frontend"
  autoscaling_group_name = aws_autoscaling_group.frontend.name
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
resource "aws_lb_listener_rule" "frontend" {
  listener_arn = data.aws_ssm_parameter.frontend_alb_listener_arn.value
  priority     = 10
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }

  condition {
    host_header {
      values = ["${var.environment}.${var.domain}"]
    }
  }
}