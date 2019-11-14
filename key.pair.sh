ssh-keygen
aws ec2 import-key-pair --key-name "ec2-key" --public-key-material file://~/.ssh/id_rsa.pub
