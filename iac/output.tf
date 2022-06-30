output "manager_ip" {
  description = "IP"
  value       = aws_lightsail_static_ip.instance.ip_address
}

output "private_key" {
  description = "Private key"
  value       = aws_lightsail_key_pair.instance.private_key
}

output "eks_role_arn" {
  description = "EKS role arn"
  value       = aws_iam_role.eks.arn
}

output "node_group_role_arn" {
  description = "Node group role arn"
  value       = aws_iam_role.node_group.arn
}
