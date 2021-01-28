provider "aws" {
  region ="us-east-1"
}

resource "aws_vpc" "epsi-tf" {
  cidr_block = "10.0.0.0/16"
  
  tags = {
    Name = "epsi-tf"
  }
}

resource "aws_subnet" "public-a" {
  vpc_id     = aws_vpc.epsi-tf.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  
  tags = {
    Name = "public-a-tf"
  }
}

resource "aws_subnet" "public-b" {
  vpc_id     = aws_vpc.epsi-tf.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1b"
  
  tags = {
    Name = "public-b-tf"
  }
}

resource "aws_subnet" "private-a" {
  vpc_id     = aws_vpc.epsi-tf.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-east-1a"
  
  tags = {
    Name = "private-a-tf"
  }
}

resource "aws_subnet" "private-b" {
  vpc_id     = aws_vpc.epsi-tf.id
  cidr_block = "10.0.4.0/24"
  availability_zone = "us-east-1a"
  
  tags = {
    Name = "private-b-tf"
  }
}

resource "aws_internet_gateway" "igw-tf" {
  vpc_id = aws_vpc.epsi-tf.id

  tags = {
    Name = "igw-tf"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.epsi-tf.id
  route {
  cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.igw-tf.id
}

  tags = {
    Name = "public-tf"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id = aws_subnet.public-a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "b" {
  subnet_id = aws_subnet.public-b.id
  route_table_id = aws_route_table.public.id
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

resource "aws_instance" "wordpress" {
    ami = data.aws_ami.ubuntu.id
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.allow_http.id]
    key_name = aws_key_pair.deployer.key_name
    subnet_id     = aws_subnet.public-a.id
    associate_public_ip_address = true

    tags = {
        Name = "wordpress"
    }
    
    user_data = file("${path.root}/wordpress.sh")
  }
  
  resource "aws_security_group" "allow_http" {
  name        = "allow_http"
  description = "Allow http inbound traffic"
  vpc_id      = aws_vpc.epsi-tf.id

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
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
    Name = "allow_http"
  }
}

resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "deployer" {
  key_name   = "ec2-key-tf"
  public_key = tls_private_key.example.public_key_openssh
}

resource "random_password" "dbpassword" {
  length = 16
  special = true
  override_special = "_%@"
}
