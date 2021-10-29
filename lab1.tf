# Configure the AWS Provider
provider "aws" {
  region     = "us-east-1"
  shared_credentials_file = "./credentials"
}

resource "aws_vpc" "epsi-tf" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "epsi-tf"
  }
}

resource "aws_subnet" "public-a" {
  vpc_id            = aws_vpc.epsi-tf.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "public-a-tf"
  }
}

resource "aws_subnet" "public-b" {
  vpc_id            = aws_vpc.epsi-tf.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "public-b-tf"
  }
}

resource "aws_subnet" "private-a" {
  vpc_id            = aws_vpc.epsi-tf.id
 
 
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "private-a-tf"
  }
}

resource "aws_subnet" "private-b" {
  vpc_id            = aws_vpc.epsi-tf.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1b"

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
  subnet_id      = aws_subnet.public-a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.public-b.id
  route_table_id = aws_route_table.public.id
}

resource "aws_key_pair" "deployer" {
  key_name   = "ec2-key-tf"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDENaOi82E9pE+qFz5fPqx8Jn9IlPf7BmBezbVyAQFAbpglWFNvz8Ib4Zlifvv+77FiAdT7VhAvjNDhJ5q27CYyaBwAcggdzdyDEpnxGRyzHt62twq9DpxXWg0Xx+8s7RklwyHiSTRIvd4iC+FyMtrPEIbcjfNV8QRgRhD4BLtceQH3dJFhHsjKBhH0n4ycshRhXkFJj6sOf/+iS8qTLlYJ7rqAs+s1axzLTeQrEWMyByoObj515MjPppRtxPndDF5Ap+drIKNqz2dWV0Ium1Nw1OsgQuFZca/isB0V1NYjL4eSrAMoDQZinS8UMpcE8XXN7gNQGNlW2FZOY1q/vlTrEYj4W8kCDjOtUkOLSAcBFzz8FFtl6Ji4gp5ro+otpzYv1JZaB/GVSRikIqXqqMF6VDwUTIvNiv/YP4vjGFi3SfAheikN4tYorgB6Fie2+ziTxmSo0FLncgdU/BnPbZBRdXrOBNs9Mzl8Vtch30rkWTPYiZKU2niBYe+w/oWHnZU= sebastien@LAPTOP-R2QRB1VT"
}

resource "aws_instance" "wordpress" {
  ami                         = "ami-02e136e904f3da870"
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.deployer.key_name
  subnet_id                   = aws_subnet.public-a.id
  associate_public_ip_address = true
  security_groups = [aws_security_group.allow_http.id]

  tags = {
    Name = "wordpress"
  }
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

    ingress {
    description = "HTTP from VPC"
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
  vpc_id      = aws_vpc.epsi-tf.id

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
  subnet_ids = [aws_subnet.private-a.id, aws_subnet.private-b.id]

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

resource "aws_lb_target_group" "test" {
  name     = "lb-final"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.epsi-tf.id}"
}

resource "aws_launch_configuration" "as_conf" {
  name_prefix   = "terraform-lc-example-"
  image_id      = "ami-02e136e904f3da870"
  instance_type = "t2.micro"
  associate_public_ip_address = false
  user_data = file("${path.module}/postinstall.sh")
  security_groups = [aws_security_group.allow_http.id]
  key_name        = aws_key_pair.deployer.key_name

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "bar" {
  name                 = "terraform-asg-example"
  launch_configuration = "${aws_launch_configuration.as_conf.name}"
  min_size             = 2
  max_size             = 2
  desired_capacity     = 2
  target_group_arns    = ["${aws_lb_target_group.test.arn}"]
  vpc_zone_identifier  = ["${aws_subnet.public-a.id}", "${aws_subnet.public-b.id}"]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb" "test" {
  name               = "test-lb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.allow_http.id}"]
  subnets            = ["${aws_subnet.public-a.id}", "${aws_subnet.public-b.id}"]

  tags = {
    Environment = "production"
  }
}

resource "aws_autoscaling_attachment" "asg_attachment_bar" {
  autoscaling_group_name = "${aws_autoscaling_group.bar.id}"
  alb_target_group_arn   = "${aws_lb_target_group.test.arn}"
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = "${aws_lb.test.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.test.arn}"
  }
}

resource "aws_eip" "nat" {
  vpc      = true
}

resource "aws_nat_gateway" "example" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public-b.id

  tags = {
    Name = "gw NAT"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.igw-tf]
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.epsi-tf.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.example.id
  }

  tags = {
    Name = "private-tf"
  }
}

resource "aws_route_table_association" "priva" {
  subnet_id      = aws_subnet.private-a.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "privb" {
  subnet_id      = aws_subnet.private-b.id
  route_table_id = aws_route_table.private.id
}

output "dns-name" {
  value = aws_lb.test.dns_name
}

output "public_ip" {
  value = aws_instance.wordpress.public_ip
}
