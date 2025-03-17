resource "aws_db_instance" "rds" {
  identifier           = "intruder-detection-db"
  engine              = "mysql"
  instance_class      = "db.t3.micro"
  allocated_storage   = 20
  username           = "admin"
  password           = "securepassword"
  publicly_accessible = true
  multi_az           = true
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name
}
