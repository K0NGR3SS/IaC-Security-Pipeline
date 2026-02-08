variable "environment" {
  type    = string
  default = "dev"
}

variable "aws_region" {
  type    = string
  default = "eu-west-1"
}

variable "admin_ip" {
  description = "Your IP address for SSH access (e.g., 1.2.3.4/32)"
  type        = string
}