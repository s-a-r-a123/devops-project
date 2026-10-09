variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "devops project"
}
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "11.0.0.0/16"
}

variable "subnet_1_cidr" {
  description = "CIDR for public subnet 1"
  type        = string
  default     = "11.0.11.0/24"
}

variable "subnet_2_cidr" {
  description = "CIDR for public subnet 2"
  type        = string
  default     = "11.0.12.0/24"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}}

variable "key_name" {
  description = "Existing EC2 key pair name"
  type        = string
}

variable "ghcr_image" {
  description = "Public GHCR Docker image"
  type        = string
}