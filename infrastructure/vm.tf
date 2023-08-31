data "aws_ami" "basic_images" {
  owners = ["amazon", "self"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023.1.20230725.0-kernel-6.1-x86_64"]
  }
}

resource "aws_instance" "test_vm" {
  #depends_on    = [aws_security_group.default_group.id]
  ami           = data.aws_ami.basic_images.id
  instance_type = "t2.micro"

  vpc_security_group_ids = [
    aws_security_group.ssh_group.id,
    aws_security_group.endpoint_group.id
  ]

  tags = {
    Name = "Test VM"
  }

  associate_public_ip_address = true
  subnet_id                   = aws_subnet.public.id
}
