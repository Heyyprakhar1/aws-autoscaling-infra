resource "aws_db_subnet_group" "default" {
  name       = "${var.project_name}-subnet-group"
  subnet_ids = var.private_subnet_ids
}

resource "aws_db_instance" "default" {
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "8.0"
  multi_az             = false  
  instance_class       = var.db_instance_class
  db_name              = var.db_name
  username             = var.db_username
  vpc_security_group_ids = [var.rds_sg_id]
  password             = var.db_password
  db_subnet_group_name = aws_db_subnet_group.default.name
  skip_final_snapshot  = var.skip_final_snapshot  
}
