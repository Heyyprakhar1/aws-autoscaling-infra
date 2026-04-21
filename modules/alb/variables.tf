variable "project_name" {
  description = "Name prefix for all resources"
  type        = string
  default     = "autoscaling-infra"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of subnet IDs for the ALB"
  type        = list(string)
}

variable "alb_sg_id" {
  description = "Security Group ID for the ALB"
  type        = string
}

variable "alb_name" {
  description = "Name of the ALB"
  type        = string
  default     = "alb"
}