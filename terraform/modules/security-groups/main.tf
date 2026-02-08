resource "aws_security_group" "web" {
  name_prefix = "${var.environment}-web-"
  description = "Security group for web servers"
  vpc_id      = var.vpc_id

  # HTTPS only from anywhere
  ingress {
    description = "HTTPS from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP - redirect to HTTPS
  ingress {
    description = "HTTP redirect"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH from specific admin IPs only
  dynamic "ingress" {
    for_each = var.admin_cidrs
    content {
      description = "SSH from admin"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [ingress.value]
    }
  }

  # All outbound
  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-web-sg"
  }

  lifecycle {
    create_before_destroy = true
  }
}