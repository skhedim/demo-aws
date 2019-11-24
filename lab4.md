* Install terraform in your cloud9 environment via the install-terraform script
* Open a new file in Cloud9 to write your first terraform code
* Go to https://www.terraform.io/docs/providers/aws/index.html, add the block code for the provider, Configure the us-east-1 region. 
* Add a VPC resource with a tag including terraform, and and a IP Range (10.0.0.0/16).
* Create the VPC via terraform with: “terraform init”, “terraform plan”, check the result and try to “terraform apply” Check in the AWS console to see the new VPC
* Try to destroy the VPC with “terraform destroy” and check in the AWS console
* Add a subnet to the VPC with the range 10.0.0.0/24 and a tag. Try to apply the new code.
* Now add the IGW, Route tables, and a instance. Good luck !
