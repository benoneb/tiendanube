#!/bin/bash
sudo apt-get update
sudo apt-get install -y nginx
sudo systemctl start nginx
sudo systemctl enable nginx
echo "<html><body><center><h1>Instance deployed via Terraform with NGINX</h1></html></body><style>h1 { background-color: blue; }</style>" | sudo tee /var/www/html/index.html