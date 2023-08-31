resource "aws_db_instance" "education" {
  identifier            = "emotiai-db"
  instance_class        = "db.t3.micro"
  allocated_storage     = 20
  engine                = "postgres"
  engine_version        = "15.3"
  username              = "postgres"
  password              = "test1234567"
  max_allocated_storage = 1000
  publicly_accessible   = false
  skip_final_snapshot   = true
  storage_encrypted     = true
  copy_tags_to_snapshot = true

  vpc_security_group_ids = [aws_security_group.endpoint_group.id]
  db_subnet_group_name = aws_db_subnet_group.default.name

tags = {
    Name = "Emotiai Database"
  }
}

resource "aws_db_subnet_group" "default" {
  name       = "main"
  subnet_ids = [aws_subnet.public.id, aws_subnet.private.id, aws_subnet.private-az2.id]

  tags = {
    Name = "Emotiai Database subnet group"
  }
}

locals {
  address = aws_db_instance.education.address
  username = aws_db_instance.education.username
  password = aws_db_instance.education.password
}

output "address" {
  value = aws_db_instance.education.address
}

output "username" {
  value = aws_db_instance.education.username
}

output "password" {
  value = aws_db_instance.education.password
  sensitive = true
}
