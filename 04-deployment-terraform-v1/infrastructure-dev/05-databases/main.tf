# create ec2 mongodb
# using terraform null resource ansible integration 

/* 
null resouces won't create any resource, but 
it will follow stardard life-cycle of terraform ,
we can null resourcs for connect instances 
NOTE: terraform null-resource is deprecated , instead , we can use terraform data
*/

/* 
1. connect instance
2. copy the scripts 
3. excute script
*/
/*
to integrate terraform with ansible , we will install ansible in a server 
by using ansible pull , locally do configuration , this process helps 
create master and later connect nodes etc.
Ansible pull helps to 
clone the ansible code 

write a script for install and ansible pull
*/

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
      "sudo sh /tmp/mongodb.sh mongodb"
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
      "sudo sh /tmp/redis.sh redis"
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
      "sudo sh /tmp/rabbitmq.sh rabbitmq"
    ]
  }
}


# mysql
resource "aws_instance" "mysql" {
  ami                    = data.aws_ami.custom_ami.id
  instance_type          = var.instance_type
  vpc_security_group_ids = local.mysql_sg_id
  subnet_id              = local.subnet_id
  # iam_instance_profile = data.aws_ssm_parameter.iam.value # iam role to access ssm params access
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
      "sudo sh /tmp/mysql.sh mysql"
    ]
  }
}