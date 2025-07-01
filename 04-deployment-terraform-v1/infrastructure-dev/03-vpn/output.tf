output "public_ip" {
  value = aws_instance.openvpn.public_ip
}


output "vpn_info" {
  value = templatefile("${path.module}/vpn_template.tmpl", {
    admin_url = "https://${aws_instance.openvpn.public_ip}:943/admin"
    client_url = "https://${aws_instance.openvpn.public_ip}:943/"
    username   = "openvpn"
    password   = "Admin@123"
  })
}
