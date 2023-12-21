#! /bin/bash
sudo yum update -y
sudo yum install -y httpd 
sudo systemctl enable httpd
sudo systemctl start httpd 
sudo echo '<h1>this is coming from my instance' | sudo tee /var/www/html/index.html