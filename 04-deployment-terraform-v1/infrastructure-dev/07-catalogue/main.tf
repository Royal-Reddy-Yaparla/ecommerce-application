




resource "aws_instance" "catalogue" {
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
