resource "aws_lb_target_group" "catalogue" {
  name = "${var.project}-${var.environment}-catalogue"
  ################################################################################
  # protocol = "HTTP" means:
  # - The Application Load Balancer (ALB) will forward HTTP traffic to the
  #   registered target instances (e.g., EC2) on the specified port (port = 8080).
  # - The ALB understands HTTP protocol at Layer 7 (Application Layer), allowing it to:
  #     - Perform health checks using HTTP paths (e.g., /health)
  #     - Use host-based or path-based routing rules
  #     - Inspect HTTP headers and status codes
  # NOTE: The ALB will forward only HTTP traffic to the target instances on port 8080.Enables advanced features: host-based/path-based routing, health checks using URLs like /health
  # In our case:
  # - The application (e.g., catalogue service) listens on port 8080.
  # - ALB forwards incoming HTTP requests to this port using the HTTP protocol.
  # - This setup is ideal for REST APIs or web apps running behind an ALB.
  ################################################################################
  port     = 8080
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
    port                = 8080
    path                = "/health"
    matcher             = "200-299"
  }
}


resource "aws_instance" "catalogue" {
  ami                    = data.aws_ami.custom_ami.id
  instance_type          = var.instance_type
  vpc_security_group_ids = local.catalogue_sg_id
  subnet_id              = local.subnet_id

  tags = merge(
    var.ec2_tags,
    local.common_tags,
    {
      Name = "${var.project}-${var.environment}-catalogue"
    }
  )
}

# null resources 
resource "terraform_data" "catalogue" {
  triggers_replace = [aws_instance.catalogue.id]

  provisioner "file" {
    source      = "scripts/bootstrap.sh"
    destination = "/tmp/catalogue.sh"
  }

  connection {
    type     = "ssh"
    user     = "ec2-user"
    password = "DevOps321"
    host     = aws_instance.catalogue.private_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /tmp/catalogue.sh",
      "sudo sh /tmp/catalogue.sh catalogue dev"
    ]
  }
}

# not required
# resource "aws_route53_record" "catalogue" {
#   zone_id = var.zone_id
#   name    = "catalogue-${var.environment}.${var.domain}"
#   type    = "A"
#   ttl     = 1
#   records = [aws_instance.catalogue.private_ip]
# }

# stop instance
resource "aws_ec2_instance_state" "catalogue" {
  instance_id = aws_instance.catalogue.id
  depends_on  = [terraform_data.catalogue]
  state       = "stopped"
}

# take AMI from instance
resource "aws_ami_from_instance" "catalogue" {
  name = "${var.project}-${var.environment}-catalogue"

  depends_on         = [aws_ec2_instance_state.catalogue]
  source_instance_id = aws_ec2_instance_state.catalogue.id

  tags = merge(
    var.ec2_tags,
    local.common_tags,
    {
      Name = "${var.project}-${var.environment}-catalogue"
    }
  )
}

# terminate instance 
# null resources 
resource "terraform_data" "catalogue_terminate" {
  triggers_replace = [aws_ec2_instance_state.catalogue.id]
  depends_on       = [aws_ami_from_instance.catalogue]

  provisioner "local-exec" {
    command = "aws ec2 terminate-instances --instance-ids ${aws_ec2_instance_state.catalogue.id}"
  }
}

# launch template
resource "aws_launch_template" "catalogue" {
  name = "${var.project}-${var.environment}-catalogue"

  image_id               = aws_ami_from_instance.catalogue.id
  instance_type          = var.instance_type
  vpc_security_group_ids = local.catalogue_sg_id

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
        Name = "${var.project}-${var.environment}-catalogue"
      }
    )
  }
  # volume-tags
  tag_specifications {
    resource_type = "volume"

    tags = merge(
      local.common_tags,
      {
        Name = "${var.project}-${var.environment}-catalogue"
      }
    )
  }

  # launch template tags
  tags = merge(
    local.common_tags,
    {
      Name = "${var.project}-${var.environment}-catalogue"
    }
  )
}

# auto-scaling 
resource "aws_autoscaling_group" "catalogue" {
  name = "${var.project}-${var.environment}-catalogue"

  desired_capacity = 1
  max_size         = 10
  min_size         = 1

  # checking health of ELB  
  health_check_grace_period = 90 # grace period to check health after launch
  health_check_type         = "ELB"

  vpc_zone_identifier = local.private_subnet_ids

  # push new instances those created in auto-scaling to target group
  target_group_arns = [aws_lb_target_group.catalogue.arn]

  # take latest version of launch template
  launch_template {
    id      = aws_launch_template.catalogue.id
    version = aws_launch_template.catalogue.latest_version
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
        Name = "${var.project}-${var.environment}-catalogue"
      }
    )
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}


resource "aws_autoscaling_policy" "example" {
  name                   = "${var.project}-${var.environment}-catalogue"
  autoscaling_group_name = aws_autoscaling_group.catalogue.name
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
resource "aws_lb_listener_rule" "catalogue" {
  listener_arn = data.aws_ssm_parameter.backend_alb_listener_arn.value
  priority     = 10
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.catalogue.arn
  }

  condition {
    host_header {
      values = ["catalogue.backend-${var.environment}.${var.domain}"]
    }
  }
}