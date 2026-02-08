variable "environment" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "admin_cidrs" {
  description = "Admin IP addresses allowed for SSH"
  type        = list(string)
  default     = []
}