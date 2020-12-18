# VPC

10.0.0.0/16

# 4 subnets

2 publiques 10.0.1.0/24 - 10.0.2.0/24 zone A-B
2 privés 10.0.3.0/24 - 10.0.4.0/24 zone A-B

# Internet Gateway

# NAT Gateway

# 2 Route table

Publique - Subnets publiques vers l’internet Gateway
Association des subnets publiques
Privé - subnets privés vers la Nat GW
Association des subnets privés

# Target Group

# Launch configuration

Instance type: T2.micro
AMI Ubuntu (à récupérer via une data)
user_data: Installation de apache2
key_pair: utiliser ec2-key

# Security groups

Allow 80 -> 0.0.0.0/0 

# Autoscaling Group

min = 1 max = 3

# Load Balancer

Application load balancer
Accessible depuis internet
