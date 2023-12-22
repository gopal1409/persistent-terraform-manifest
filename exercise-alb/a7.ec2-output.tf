output "instance_app_server_public_dn" {
  description = "This is the dns of all your instance"
  value = aws_instance.ec2demo.*.public_dns
}

output "instance_app_server_public_ip" {
  description = "This is the ip of all your instance"
  value = aws_instance.ec2demo.*.public_ip
}