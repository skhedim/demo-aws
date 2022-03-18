provider "aws" {
  region     = "us-east-1"
  access_key = "ASIAZWEC3M2P72RX7R6G"
  secret_key = "LSBtu1Qv6p3oxZqx+DjQ7uS6I8iG4k6fVkD96hCY"
  token      = "FwoGZXIvYXdzEFYaDKkqE6bvrepM5uLkSiK9AY6e92xKG1KbRVFLYtk3/Bzq9W0DJqIx7SQR5bUB/0lwIN5SQL6gzDpuPrxsINF6lqlirgKugy9MNsNHnRMaBTRkrVwz/nblNJXMWbanGOJKkQojO99YDF1FqL7HEg5NPI66oZYihA6v7gk5OU0CK52rGjL6Af9KFRbEQHtmoXVDfsbC8HH3J2dgtutbv9Yd6mgDoHilw6bDIocp2KFRiiQTOQlU36yyCkmpBSSqkMH32+J4zaEj1d/wMbcppCjS9dGRBjItASrjOt7q3gMPZrej6iJzqVEyQ5RzKYMH52RXt0m0q+uZou8ai7NmYAVfyNWG"
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

resource "random_password" "dbpassword" {
  length  = 16
  special = false
}

resource "aws_security_group" "allow_rds" {
  name        = "allow_rds"
  description = "Allow mysql inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.allow_http.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_http-tf"
  }
}

resource "aws_db_subnet_group" "rds" {
  name       = "wordpress"
  subnet_ids =[aws_subnet.private-a.id, aws_subnet.private-b.id]

  tags = {
    Name = "wordpress-rds"
  }
}

resource "aws_db_instance" "dbWordPress" {
  engine                 = "mysql"
  engine_version         = "5.7"
  allocated_storage      = 20
  instance_class         = "db.t2.micro"
  vpc_security_group_ids = [aws_security_group.allow_rds.id]
  db_subnet_group_name   = aws_db_subnet_group.rds.name
  name                   = "wordpress"
  username               = "admin"
  password               = random_password.dbpassword.result
  skip_final_snapshot    = true

  tags = {
    Name = "WordPress DB"
  }
}

output "db_password" {
  value = random_password.dbpassword.result
  sensitive = true
}

output "public_ip" {
  value = aws_instance.wordpress.public_ip
}
