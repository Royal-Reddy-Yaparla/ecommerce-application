################################################################################
# EC2 MongoDB Provisioning with Terraform + terraform_data + Ansible Pull
#
#  Purpose:
# - Provision a MongoDB EC2 instance.
# - Use Terraform's `terraform_data` block (replacement for deprecated null_resource)
#   to handle post-provision configuration via SSH.
#
#  What This Setup Does:
# 1. Creates an EC2 instance for MongoDB.
# 2. Uses `terraform_data` to:
#    - Connect to the EC2 instance via SSH.
#    - Copy a bootstrap script (e.g., install MongoDB by ansible pull, setup config).
#    - Execute the script with arguments (`mongodb dev`).
#
#  Connection Details:
# - SSH connection using the default user (e.g., ec2-user) and password.
#   (Note: Password-based SSH is not recommended in production.)
#
#  Deprecation Note:
# - `null_resource` is deprecated.
# - `terraform_data` is the modern alternative that supports provisioners and triggers.
#
#  Ansible Integration (Concept):
# - In real use-cases, a central Ansible master can be setup.
# - Each EC2 node can be configured using `ansible-pull`, which:
#   - Pulls Ansible code from a Git repo.
#   - Applies configuration locally.
#   - Helps decentralize provisioning and avoids agent requirements.
#
# - Bootstrapping instances with light provisioning.
# - Running one-time setup tasks like MongoDB installation.
# - Integrating with existing Ansible workflows.
################################################################################

# mongodb
resource "aws_instance" "mongodb" {
  ami                    = data.aws_ami.custom_ami.id
  instance_type          = var.instance_type
  vpc_security_group_ids = local.mongodb_sg_id
  subnet_id              = local.subnet_id

  tags = merge(
    var.ec2_tags,
    local.common_tags,
    {
      Name = "${var.project}-${var.environment}-mongodb"
    }
  )
}

# null resouces 
resource "terraform_data" "mongodb" {
  triggers_replace = [aws_instance.mongodb.id]
  provisioner "file" {
    source      = "scripts/bootstrap.sh"
    destination = "/tmp/mongodb.sh"
  }
  connection {
    type     = "ssh"
    user     = "ec2-user"
    password = "DevOps321"
    host     = aws_instance.mongodb.private_ip
  }
  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /tmp/mongodb.sh",
      "sudo sh /tmp/mongodb.sh mongodb dev"
    ]
  }
}

# redis
resource "aws_instance" "redis" {
  ami                    = data.aws_ami.custom_ami.id
  instance_type          = var.instance_type
  vpc_security_group_ids = local.redis_sg_id
  subnet_id              = local.subnet_id

  tags = merge(
    var.ec2_tags,
    local.common_tags,
    {
      Name = "${var.project}-${var.environment}-redis"
    }
  )
}

# null resouces
resource "terraform_data" "redis" {
  triggers_replace = [aws_instance.redis.id]
  provisioner "file" {
    source      = "scripts/bootstrap.sh"
    destination = "/tmp/redis.sh"
  }
  connection {
    type     = "ssh"
    user     = "ec2-user"
    password = "DevOps321"
    host     = aws_instance.redis.private_ip
  }
  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /tmp/redis.sh",
      "sudo sh /tmp/redis.sh redis dev"
    ]
  }
}


# rabbitmq
resource "aws_instance" "rabbitmq" {
  ami                    = data.aws_ami.custom_ami.id
  instance_type          = var.instance_type
  vpc_security_group_ids = local.rabbitmq_sg_id
  subnet_id              = local.subnet_id

  tags = merge(
    var.ec2_tags,
    local.common_tags,
    {
      Name = "${var.project}-${var.environment}-rabbitmq"
    }
  )
}

# null resouces
resource "terraform_data" "rabbitmq" {
  triggers_replace = [aws_instance.rabbitmq.id]
  provisioner "file" {
    source      = "scripts/bootstrap.sh"
    destination = "/tmp/rabbitmq.sh"
  }
  connection {
    type     = "ssh"
    user     = "ec2-user"
    password = "DevOps321"
    host     = aws_instance.rabbitmq.private_ip
  }
  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /tmp/rabbitmq.sh",
      "sudo sh /tmp/rabbitmq.sh rabbitmq dev"
    ]
  }
}


# mysql
resource "aws_instance" "mysql" {
  ami                    = data.aws_ami.custom_ami.id
  instance_type          = var.instance_type
  vpc_security_group_ids = local.mysql_sg_id
  subnet_id              = local.subnet_id
  iam_instance_profile   = "EcomAdminAccess" # iam role to access ssm params access
  tags = merge(
    var.ec2_tags,
    local.common_tags,
    {
      Name = "${var.project}-${var.environment}-mysql"
    }
  )
}

# null resouces
resource "terraform_data" "mysql" {
  triggers_replace = [aws_instance.mysql.id]
  provisioner "file" {
    source      = "scripts/bootstrap.sh"
    destination = "/tmp/mysql.sh"
  }
  connection {
    type     = "ssh"
    user     = "ec2-user"
    password = "DevOps321"
    host     = aws_instance.mysql.private_ip
  }
  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /tmp/mysql.sh",
      "sudo sh /tmp/mysql.sh mysql dev"
    ]
  }
}

resource "aws_route53_record" "mysql" {
  zone_id = var.zone_id
  name    = "mysql-${var.environment}.${var.domain}"
  type    = "A"
  ttl     = 1
  records = [aws_instance.mysql.private_ip]
}

resource "aws_route53_record" "mongodb" {
  zone_id = var.zone_id
  name    = "mongodb-${var.environment}.${var.domain}"
  type    = "A"
  ttl     = 1
  records = [aws_instance.mongodb.private_ip]
}

resource "aws_route53_record" "redis" {
  zone_id = var.zone_id
  name    = "redis-${var.environment}.${var.domain}"
  type    = "A"
  ttl     = 1
  records = [aws_instance.redis.private_ip]
}

resource "aws_route53_record" "rabbitmq" {
  zone_id = var.zone_id
  name    = "rabbitmq-${var.environment}.${var.domain}"
  type    = "A"
  ttl     = 1
  records = [aws_instance.rabbitmq.private_ip]
}
