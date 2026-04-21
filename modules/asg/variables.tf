variable "name_prefix" {
  description = "Name prefix for all resources"
  type        = string
  default     = "autoscaling-infra"
}

variable "image_id" {
  description = "AMI ID for the EC2 instances"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "desired_capacity" {
  description = "Desired number of instances in the Auto Scaling group"
  type        = number
  default     = 2
}

variable "max_size" {
  description = "Maximum number of instances in the Auto Scaling group"
  type        = number
  default     = 4
}

variable "min_size" {
  description = "Minimum number of instances in the Auto Scaling group"
  type        = number
  default     = 1
}

variable "target_group_arn" {
  description = "ARN of the target group to attach the Auto Scaling group to"
  type        = string
}

variable "scaling_adjustment" {
  description = "Number of instances to add or remove when scaling"
  type        = number
  default     = 1
}

variable "private_subnet_ids" {
  description = "List of subnet IDs for the Auto Scaling group"
  type        = list(string)
}

variable "key_name" {
  description = "Key pair name for SSH access to the EC2 instances"
  type        = string
}

variable "ec2_sg_id" {
  description = "Security Group ID for the EC2 instances"
  type        = string
}