#!/bin/bash
sudo apt-get update
sudo apt-get install -y apache2
sudo systemctl start apache2
sudo systemctl enable apache2
echo "<html><body><center><h1>Instance deployed via Terraform with Apache</h1></html></body>" | sudo tee /var/www/html/index.html