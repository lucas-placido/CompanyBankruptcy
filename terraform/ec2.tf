resource "aws_instance" "tf-ec2-instance" {
  ami           = "ami-022e1a32d3f742bd8" # Amazon Machine Image
  instance_type = "t3.micro"
  vpc_security_group_ids = [aws_security_group.my-security-group.id]
  key_name = "key-pair"
  user_data = file("ec2-commands.sh")

  tags = {
    Name = "tf-ec2"
  }
}

resource "aws_security_group" "my-security-group" {
  name        = "my-security-group"
  description = "Allow inbound SSH and outbound internet access"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "my-security-group"
  }
}