variable "aws_region" {
  description = "AWS region where resources will be created."
  type        = string
}

variable "project_id" {
  description = "Project identifier used for resource tagging."
  type        = string
}

variable "vpc_name" {
  description = "Name of the existing VPC."
  type        = string
}

variable "public_subnet_a_cidr" {
  description = "CIDR block of public subnet A."
  type        = string
}

variable "private_subnet_a_cidr" {
  description = "CIDR block of private subnet A."
  type        = string
}

variable "public_subnet_b_cidr" {
  description = "CIDR block of public subnet B."
  type        = string
}

variable "private_subnet_b_cidr" {
  description = "CIDR block of private subnet B."
  type        = string
}

variable "ec2_security_group_name" {
  description = "Name of the existing EC2 SSH security group."
  type        = string
}

variable "http_security_group_name" {
  description = "Name of the existing EC2 HTTP security group."
  type        = string
}

variable "load_balancer_security_group_name" {
  description = "Name of the existing load balancer security group."
  type        = string
}

variable "key_pair_name" {
  description = "Name of the existing EC2 key pair."
  type        = string
}

variable "instance_profile_name" {
  description = "Name of the existing IAM instance profile."
  type        = string
}

variable "launch_template_name" {
  description = "Name of the EC2 Launch Template."
  type        = string
}

variable "autoscaling_group_name" {
  description = "Name of the Auto Scaling Group."
  type        = string
}

variable "load_balancer_name" {
  description = "Name of the Application Load Balancer."
  type        = string
}

variable "target_group_name" {
  description = "Name of the load balancer target group."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type used by the Launch Template."
  type        = string
}

variable "ami_name_regex" {
  description = "Regular expression used to find the Amazon Linux 2023 AMI."
  type        = string
}

variable "ami_owners" {
  description = "List of trusted AMI owners."
  type        = list(string)
}
