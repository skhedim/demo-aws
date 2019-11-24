* Create a DB subnet group with the 2 private subnets
* Create a SG to authorize the web server to access  the RDS instance (3306 port)
* Create a RDS instance with MySQL engine, Free tier option, choose your previously created subnet group and SG
* Connect to the web server via Cloud9 terminal 
* Apply the wordpress script at this address https://github.com/skhedim/demo-aws
* Connect to the RDS instance via the web server instance using mysql CLI: mysql -u admin -p -h YOUR-RDS-endpoint
* Create a database for the website: CREATE DATABASE wordpress;  then quit the terminal: QUIT;
* Configure the database connection from your web browser via the public IP of your web server instance
