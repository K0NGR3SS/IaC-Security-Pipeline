output "instance_details" {
  description = "Instance details for Ansible"
  value = [
    for i in aws_instance.web : {
      name       = i.tags["Name"]
      public_ip  = i.public_ip
      private_ip = i.private_ip
      id         = i.id
      tags       = i.tags
    }
  ]
}