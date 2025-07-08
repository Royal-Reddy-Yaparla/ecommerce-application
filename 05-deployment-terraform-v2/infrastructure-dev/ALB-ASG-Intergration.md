## ALB and Auto Scaling Terraform Setup 
### Purpose

To set up a scalable and highly available infrastructure using:

* **Application Load Balancer (ALB)** for routing traffic
* **Auto Scaling Group** for managing EC2 instances based on demand

---

## Part 1: Application Load Balancer (ALB) Setup

### Steps Followed

1. **Created an Application Load Balancer**

   * Internal ALB for backend , Public ALB for frontend
   * Deployed into **private subnets** for backend / Deployed into **public subnets** for frontend 
   * Used common tags and security groups
   * Created by using `terraform-aws-modules/alb/aws`

2. **Created a Listener on Port 80**

   * Default action: `fixed-response`
   * Returns message: `"Hello I am  Load-Balancer"`

3. **Mapped ALB DNS to Route53**

   * Used `aws_route53_record` resource
   * Alias record pointing to ALB DNS

4. **Created Target Group** (from `main.tf`)
    **Backend** 
   * Forwards HTTP traffic to app on port `8080`
   * Health check path: `/health`
   * Target type: `instance`

5. **Added Listener Rules**

   * Conditionally forwards requests based on host/path to appropriate **target group**

### Request Flow

```text
ALB URL → Listener (port 80) 
       → Rule (host/path match) 
       → Target Group 
       → EC2 Instance
```

---

## Part 2: Auto Scaling Group Setup

### Steps Followed

1. **Provisioned and Configured EC2 Instance**

   * Installed the backend application
   * Ensured port `8080` is open via security group

2. **Stopped the Instance**

   * Prevented app updates while capturing the image

3. **Created AMI (Amazon Machine Image)**

   * Used as golden image for scaling

4. **Terminated the EC2 Instance**

   * No longer needed after AMI creation

5. **Created Launch Template**

   * Used the above AMI
   * Included instance type, security group, key pair, user data (if any)

6. **Created Auto Scaling Group**

   * Referenced the launch template
   * Defined:

     * Min/Max/Desired capacity
     * Subnets
     * Health check type: ELB
   * **Attached to the ALB target group**

7. **Created Scaling Policy**

   * CPU Utilization > 70% → scale out
   * Cooldown: 300 seconds
   * Scale in when CPU < 30%

### Instance Lifecycle (Auto Scaling Flow)

```text
Launch Template → Auto Scaling Group → EC2 Instance → ALB Target Group → ALB Listener → Route53 DNS
```

---

## Terraform Configuration Snapshot

### ALB Configuration (`alb.tf`)

```hcl
module "alb" {
  source                    = "terraform-aws-modules/alb/aws"
  name                      = "${var.project}-${var.environment}-backend-alb"
  vpc_id                    = local.vpc_id
  subnets                   = local.private_subnet_ids
  security_groups           = local.security_group_ids
  internal                  = true
  enable_deletion_protection = false

  tags = merge(
    var.alb_tags,
    local.common_tags,
    {
      Name = "${var.project}-${var.environment}-backend-alb"
    }
  )
}

resource "aws_lb_listener" "backend" {
  load_balancer_arn = module.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/html"
      message_body = "Hello I am Backend Load-Balancer"
      status_code  = "200"
    }
  }
}

resource "aws_route53_record" "backend-alb" {
  zone_id = var.zone_id
  name    = "backend.${var.domain_name}"
  type    = "A"

  alias {
    name                   = module.alb.dns_name
    zone_id                = module.alb.zone_id
    evaluate_target_health = true
  }
}
```

### Target Group and Health Check (`main.tf`)

```hcl
resource "aws_lb_target_group" "catalogue" {
  name        = "${var.project}-${var.environment}-catalogue"
  protocol    = "HTTP"
  port        = 8080
  target_type = var.target_type
  vpc_id      = var.vpc_id

  health_check {
    path                = "/health"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-399"
  }

  tags = {
    Name        = "${var.project}-${var.environment}-catalogue"
    Environment = var.environment
    Project     = var.project
  }
}
```

---
