* Create a NAT GW and attach it to a public subnet.
* Create an EC2 instance with a minimal web server in a private subnet without public IP
* Create an AMI from the previously created instance
* Create a route table; with a route 0.0.0.0/0 —> NAT GW, and attach it to the private subnets.
* Create a Target Group for the autoscaling group
* Create a Configuration template with the previously created AMI and add the web server security group
* Create the autoscaling group associated to the configuration template, scale from 1 to 3 based on CPU usage (20%).
* Edit the details of the autoscaling group and add it to the previously created target group
* Create an ALB and add the previously created target group to it.
* Try to access your website via the load balancer DNS name
* Connect into a scaled machine and generate CPU utilization with this command: while true;do a=1;done 
