output "manager_ip" {
  description = "IP"
  value       = aws_lightsail_static_ip.instance.ip_address
}

output "private_key" {
  description = "Private key"
  value       = aws_lightsail_key_pair.instance.private_key
}
