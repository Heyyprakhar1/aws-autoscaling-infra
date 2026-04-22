variable "project_name" {
    description = "The name of the project, used for naming resources."
    type        = string
}

variable "asg_name" {
    description = "The name of the Auto Scaling Group to monitor."
    type        = string
}

variable "scale_up_policy_arn" {
    description = "The ARN of the scaling policy to execute when scaling up."
    type        = string
}

variable "scale_down_policy_arn" {
    description = "The ARN of the scaling policy to execute when scaling down."
    type        = string
}

variable "Environment" {
    description = "The environment (e.g., dev, staging, prod) for tagging resources."
    type        = string
}
