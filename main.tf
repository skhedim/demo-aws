provider "aws" {
  version = "~> 2.0"
  region  = "us-east-1"
}

resource "aws_vpc" "default" {
  cidr_block = "10.0.0.0/16"
  
  tags = {
    Name = "terraform"
  }
}

resource "aws_subnet" "public-a" {
  vpc_id     = "${aws_vpc.default.id}"
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "public-a-tf"
  }
}

resource "aws_subnet" "public-b" {
  vpc_id     = "${aws_vpc.default.id}"
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "public-b-tf"
  }
}

resource "aws_subnet" "private-a" {
  vpc_id     = "${aws_vpc.default.id}"
  cidr_block = "10.0.3.0/24"

  tags = {
    Name = "private-a-tf"
  }
}

resource "aws_subnet" "private-b" {
  vpc_id     = "${aws_vpc.default.id}"
  cidr_block = "10.0.4.0/24"

  tags = {
    Name = "private-b-tf"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.default.id}"

  tags = {
    Name = "igw-tf"
  }
}

resource "aws_route_table" "r" {
  vpc_id = "${aws_vpc.default.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }
  tags = {
    Name = "internet-tf"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = "${aws_subnet.public-a.id}"
  route_table_id = "${aws_route_table.r.id}"
}

resource "aws_route_table_association" "b" {
  subnet_id      = "${aws_subnet.public-b.id}"
  route_table_id = "${aws_route_table.r.id}"
}
