resource "aws_lb" "main" {
  internal           = false
  load_balancer_type = "application"
  name               = "${var.project_name}-alb"
  security_groups    = [var.alb_sg_id]
  subnets           = var.public_subnet_ids

  tags = {
    Name        = "${var.project_name}-alb"
    Environment = var.environment
    }
}
resource "aws_lb_target_group" "main" {
  name               = "${var.project_name}-tg"
  port               = 80
  protocol           = "HTTP"
  target_type        = "instance"
  vpc_id             = var.vpc_id
  health_check {
    path = "/"
    matcher = "200"
    }
}
resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
     }
}