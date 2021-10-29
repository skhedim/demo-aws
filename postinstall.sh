#!/bin/bash

yum install -y httpd
cat <<EOF > /var/www/html/index.html
<html>
<body>
<h1>Hello Your Name</h1>
<p>hostname is: $(hostname)</p>
</body>
</html>
EOF
systemctl restart apache2
systemctl enable apache2
