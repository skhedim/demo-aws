provider "aws" {
  region = "eu-west-1"
}

resource "aws_instance" "web" { // création de VM
  ami           = "ami-0ee415e1b8b71305f" // OS pour la VM
  instance_type = "t2.micro" // Memoire-CPU de la VM
  subnet_id     = aws_subnet.main.id // Subnet créé ligne23
  associate_public_ip_address = true //Attribution d'une IP publique
  
  tags = {
    Name = "khedim" // Nom de la VM
  }
}

data "aws_vpc" "selected" {
}

resource "aws_subnet" "main" {
  vpc_id     = data.aws_vpc.selected.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "subnet-a"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = data.aws_vpc.selected.id
  tags = {
    Name = "igw-epsi"
  }
}

resource "aws_route_table" "example" {
  vpc_id = data.aws_vpc.selected.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "public"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.example.id
}
