provider "aws" {
  region     = "us-east-1"
  access_key = "ASIAZWEC3M2PWPFQRQ74"
  secret_key = "azj9q2VYulpgAQNA5hSNSGBs3vprLHW35EtPigg1"
  token      = "FwoGZXIvYXdzEFIaDDDUSBXU+u6wgLVA2SK9AW8sAZWTwRIJKMFD9pnMBBeXsCewWxTeSTAO0X2HgpOcm8/N84c0d4/ySd4VM8UkAJe8jD83i1cif0EHt/tpZBmx5C2qYkoGKdJqkH8jN/MPrX4wJ4NGbDJWxYOJLp0usNulL/nqc50PMVNS9ZNJKk520yc/WRiVWk4dQJqzhsJEP9dUQo0dSHITyEsi81a38oSdOe99ACzadeM1lwmPtqOu0LuA9L3iamFTRo6Ksyz0YeU2xfeSQam2tJzsJyi7/9CRBjItiJYLGiOsC2mcj5TYk8lgY7yC6LDLdtLYrVkIDJ8KCssgjZUz8HG8XBE33I5r"
}

resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"

  tags = {
    Name = "CESI"
  }
}

resource "aws_subnet" "public-a" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "public-a"
  }
}

resource "aws_subnet" "public-b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "public-b-tf"
  }
}

resource "aws_subnet" "private-a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "private-a-tf"
  }
}

resource "aws_subnet" "private-b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "private-b-tf"
  }
}

resource "aws_internet_gateway" "igw-tf" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "igw-tf"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw-tf.id
  }

  tags = {
    Name = "public-tf"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public-a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.public-b.id
  route_table_id = aws_route_table.public.id
}

resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# chmod 600 myprivatekey.pem
resource "aws_key_pair" "deployer" {
  key_name   = "ec2-key-tf"
  public_key = tls_private_key.example.public_key_openssh
  
  provisioner "local-exec" {
    command = "echo '${tls_private_key.example.private_key_pem}' > ./myprivatekey.pem"     
  }
}

resource "aws_instance" "wordpress" {
  ami                         = "ami-0c02fb55956c7d316"
  instance_type               = "t2.micro"
  vpc_security_group_ids      = [aws_security_group.allow_http.id]
  key_name                    = aws_key_pair.deployer.key_name
  subnet_id                   = aws_subnet.public-a.id
  associate_public_ip_address = true

   tags = {
    Name = "webserver-tf"
  }
}

resource "aws_security_group" "allow_http" {
  name        = "allow_http"
  description = "Allow http inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP for all"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH from VPC"
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
    Name = "allow_http"
  }
}

output "public_ip" {
  value = aws_instance.wordpress.public_ip
}
