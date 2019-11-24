Create four subnets: two in us-east-1a, two in in us-east-1b.
Create an Internet Gateway and attach it to the VPC.
Create a route table; with a route 0.0.0.0/0 —> IGW, and attach it to the public subnets.
Deploy a Cloud9 environment in the public subnet.
Generate a key pair using Cloud9 terminal and the “ssh-keygen” Linux command.
Import the key into AWS via the cloud9 terminal and the following command:                                                                      aws ec2 import-key-pair --key-name "ec2-key" --public-key-material file://~/.ssh/id_rsa.pub
Create an EC2 Instance with the following parameters: Ubuntu 18.04 64 bits, t2.micro, 8GB disk size, public-subnet, auto-assign public ip: enable, and choose the “ec2-key” key pair.
Edit the associated security group to add HTTP from anywhere in inbound rules.
Connect to the instance via Cloud9 terminal: “ssh ubuntu@IP”
Try to update your package repositories with the command: sudo apt-get update 
