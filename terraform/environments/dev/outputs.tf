output "instance_ips" {
  description = "Instance details for Ansible"
  value       = module.compute.instance_details
}

output "vpc_id" {
  value = module.vpc.vpc_id
}