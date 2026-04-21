resource "aws_launch_template" "main" {
    name_prefix  = "${var.name_prefix}-lt"
    image_id     = var.image_id
    instance_type = var.instance_type
    vpc_security_group_ids = [var.ec2_sg_id]
    key_name = var.key_name

    user_data = base64encode(<<-EOF
                #!/bin/bash
                echo "Hello, World!" > /var/www/html/index.html
                EOF
            )
}

resource "aws_autoscaling_group" "main" {
    vpc_zone_identifier = var.private_subnet_ids
    desired_capacity    = var.desired_capacity
    max_size            = var.max_size
    health_check_type   = "ELB"
    min_size            = var.min_size
    target_group_arns   = [var.target_group_arn]
    launch_template {
        id      = aws_launch_template.main.id
        version = "$Latest"
    }
}

resource "aws_autoscaling_policy" "main" {
    name                   = "${var.name_prefix}-policy"
    scaling_adjustment      = var.scaling_adjustment
    policy_type             = "SimpleScaling"
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 300
    autoscaling_group_name = aws_autoscaling_group.main.name
}