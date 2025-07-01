output "public_ip" {
  value = aws_instance.openvpn.public_ip
}


output "vpn_info" {
  value = templatefile("${path.module}/vpn_template.tmpl", {
    admin_url = "https://vpn-dev.royalreddy.site/admin/"
    client_url = "https://vpn-dev.royalreddy.site/"
    username   = "openvpn"
    password   = "Admin@123"
  })
}
