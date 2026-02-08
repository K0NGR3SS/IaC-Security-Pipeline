terraform {
  required_version = ">= 1.5.0"

  backend "s3" {
    bucket         = "your-terraform-state-bucket"
    key            = "dev/terraform.tfstate"
    region         = "eu-west-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = var.environment
      ManagedBy   = "terraform"
      Project     = "iac-security-pipeline"
    }
  }
}

# VPC Module
module "vpc" {
  source = "../../modules/vpc"

  environment = var.environment
  cidr_block  = "10.0.0.0/16"
  azs         = ["eu-west-1a", "eu-west-1b"]
  
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.101.0/24", "10.0.102.0/24"]
  
  enable_nat_gateway = true
  enable_flow_logs   = true
}

# Security Groups Module
module "security_groups" {
  source = "../../modules/security_groups"

  environment = var.environment
  vpc_id      = module.vpc.vpc_id
  admin_cidrs = [var.admin_ip]
}

# Compute Module
module "compute" {
  source = "../../modules/compute"

  environment        = var.environment
  instance_count     = 1
  instance_type      = "t3.micro"
  subnet_id          = module.vpc.public_subnets[0]
  security_group_ids = [module.security_groups.web_sg_id]
  volume_size        = 20
}