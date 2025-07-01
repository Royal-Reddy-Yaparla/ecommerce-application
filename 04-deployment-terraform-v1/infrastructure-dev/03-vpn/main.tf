# create ec2 by terraform resources with openVPN AMI and  add userdata for configuration openVPN server.
# create key-pair
resource "aws_key_pair" "vpn-key" {
  key_name   = "ecom-project"
  public_key = file("keys/ecom-project.pub")
}

# create ec2
resource "aws_instance" "openvpn" {
  ami                    = data.aws_ami.vpn_ami.id
  instance_type          = var.instance_type
  vpc_security_group_ids = local.security_group_ids
  key_name               = aws_key_pair.vpn-key.key_name
  subnet_id              = local.subnet_id
  user_data              = file("vpn-config.sh")

  tags = merge( # to merge maps
    local.common_tags,
    var.vpn_tags,
    {
      Name = "${var.project}-${var.environment}-vpn"
    }
  )
}

resource "aws_route53_record" "vpn" {
  zone_id = var.zone_id
  name    = "vpn-${var.environment}.${var.domain}"
  type    = "A"
  ttl     = 1
  records = [aws_instance.openvpn.public_ip]
}
