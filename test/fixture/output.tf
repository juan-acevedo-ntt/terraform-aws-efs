output "vpc_cidr" {
  value = aws_vpc.main.cidr_block
}

output "efs_arn" {
  value       = module.efs.arn
  description = "EFS ARN"
}

output "efs_id" {
  value       = module.efs.id
  description = "EFS ID"
}

output "efs_mount_target_ids" {
  value       = module.efs.mount_target_ids
  description = "List of EFS mount target IDs (one per Availability Zone)"
}

output "efs_mount_target_ips" {
  value       = module.efs.mount_target_ips
  description = "List of EFS mount target IPs (one per Availability Zone)"
}

output "efs_network_interface_ids" {
  value       = module.efs.network_interface_ids
  description = "List of mount target network interface IDs"
}

output "security_group_id" {
  value       = module.efs.security_group_id
  description = "EFS Security Group ID"
}

output "security_group_name" {
  value       = module.efs.security_group_name
  description = "EFS Security Group name"
}