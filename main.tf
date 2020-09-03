provider "aws" {
  region = "us-east-1"
}

#############################################################
# Data sources to get VPC and default security group details
#############################################################

data "aws_vpc" "default" {
  default = true
}

data "aws_security_group" "default" {
  name   = "default"
  vpc_id = module.web-servers-vpc.vpc_id
}

data "aws_canonical_user_id" "current" {}

################################################
# VPC for web-servers
###############################################
module "web-servers-vpc" {
  source = "./modules/aws-vpc/"

  name = "web-servers-vpc"

  cidr = "10.20.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["10.20.1.0/24", "10.20.2.0/24"]
  public_subnets  = ["10.20.101.0/24", "10.20.102.0/24"]

  enable_ipv6 = false

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    Owner       = "benone"
    Environment = "devops"
  }

  vpc_tags = {
    author      = "benone@sredevops.cloud"
    group       = "devops-admins"
    team        = "devops"
    project     = "TiendaNube"
    application = "eShop"
    cost-center = "CustomerName"
    environment = "staging"
  }
}

################################################
# Security group for web-servers
################################################
module "web_servers_sg" {
  source = "./modules/aws-security-group/"

  name        = "web-servers-sg"
  description = "Security group with for web servers"
  vpc_id      = module.web-servers-vpc.vpc_id

  tags = {
    author      = "benone@sredevops.cloud"
    group       = "devops-admins"
    team        = "devops"
    project     = "TiendaNube"
    application = "eShop"
    cost-center = "CustomerName"
    environment = "staging"
  }

  # Open for all CIDRs defined in ingress_cidr_blocks
  ingress_cidr_blocks = ["10.20.0.0/16"]
  ingress_rules       = ["http-80-tcp", "all-icmp"]
  egress_rules        = ["all-all"]

  # Use computed value here (eg, `${module...}`). Plain string is not a real use-case for this argument.
  computed_ingress_rules           = ["ssh-tcp"]
  number_of_computed_ingress_rules = 1

  # Open to CIDRs blocks (rule or from_port+to_port+protocol+description)
  ingress_with_cidr_blocks = [
    {
      rule        = "prometheus-http-tcp"
      cidr_blocks = "10.20.0.0/16"
    },
    # {
    #   from_port   = 80
    #   to_port     = 80
    #   protocol    = "tcp"
    #   description = "Web server http port 80/TCP"
    #   cidr_blocks = "10.20.1.0/24,10.20.101.0/24"
    # },
  ]

}

module "alb_web_servers_sg" {
  source = "./modules/aws-security-group/"

  name        = "alb-web-servers-sg"
  description = "Security group with for ALB web servers"
  vpc_id      = module.web-servers-vpc.vpc_id

  tags = {
    author      = "benone@sredevops.cloud"
    group       = "devops-admins"
    team        = "devops"
    project     = "TiendaNube"
    application = "eShop"
    cost-center = "CustomerName"
    environment = "staging"
  }

  # Open for all CIDRs defined in ingress_cidr_blocks
  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp", "all-icmp"]
  egress_rules        = ["all-all"]

}

##################################################################
# EC2 instances provisioning
##################################################################


##################################################################
# Data sources to get VPC, subnet, security group and AMI details
##################################################################

data "aws_ami" "ubuntu_bionic" {
  most_recent = true
  owners      = ["${var.ubuntu_account_number}"]

  filter {
    name = "name"

    values = [
      "ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*",
    ]
  }

}

resource "aws_eip" "eip-apache" {
  vpc      = true
  instance = module.ec2-apache.id[0]
}

resource "aws_eip" "eip-nginx" {
  vpc      = true
  instance = module.ec2-nginx.id[0]
}

resource "aws_kms_key" "this" {
}

resource "aws_network_interface" "this" {
  count = 2

  subnet_id = module.web-servers-vpc.public_subnets[count.index]
}

resource "aws_key_pair" "deploy" {
  key_name   = "provisioning-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDBgoz8UbIWQE+ejSrV8ftkTN138gBfuFFVaT6CrQNHXGd70kel1oK9AGQBEcYXMMdcSqJuUV2rytRd/04xLg7lM0qG4bNBAUc5Uy+21YX8ERUUfVb7ZePD9FOy3CvAtL4YEaxJGfYzUy4jvI5xGFQfXySFlybnbmBqjCj8vd6sRxJ4JrYDaMGvRs8uYBBZMyluvIblLcVrc9X1Op/y9UoI+PNMAbK80i/I5ASzvHquAprvCUOhNtrOOSVpleED7BX0AYkcv+3OW18V/HKS6c/mBdGfO/bGJ4Rxubm7s2ePCh7tbS7+dzWVWZIGIgVGXCCJe3l5cHDwusfF9Q//s2ijfuJIuTmYO4i0KPnfz3vhrr3sC0Y2L6wuXk9xPmQwGOPWYTblEjCchbd33Kd7zlhfDDiYWdy1PkZz3sj8YXNIBnzyDpveB9ejNyX1QAwuH8wskl+g64cz1j22ev20Lo4PdrOp4OTpBMwEx1gapP23s0rBwEgneceSVaMkj5LkuaczROUwfMW8dh/FwWvmel5TAil4Nq/riScHj0FZajzCFsTCOxlmTAJHwCfdqDFmL/KmBa+x9qfSdwsuttStbCAQgfbrHnW64LHOi7EEmriAgSN+7C9rM/kCjzSKgaFp3pDO6eMhS31Y54baBJ71EA/EGU/i+I1Fo9EE09o3iWbY1Q=="
}

# Template for initial configuration bash script for Apache
data "template_file" "apache" {
  template = "${file("templates/apache.sh")}"
}

# Template for initial configuration bash script for NginX
data "template_file" "nginx" {
  template = "${file("templates/nginx.sh")}"
}

module "ec2-apache" {
  source = "./modules/aws-ec2-instance/"

  instance_count = 1

  name                        = "web-server"
  ami                         = data.aws_ami.ubuntu_bionic.id
  instance_type               = "t2.micro"
  subnet_id                   = module.web-servers-vpc.public_subnets[0]
  private_ips                 = ["10.20.101.10"]
  vpc_security_group_ids      = [module.web_servers_sg.this_security_group_id]
  associate_public_ip_address = true
  key_name                    = "provisioning-key"

  user_data = "${data.template_file.apache.rendered}"

  root_block_device = [
    {
      volume_type = "gp2"
      volume_size = 10
    },
  ]

  #   ebs_block_device = [
  #     {
  #       device_name = "/dev/sdf"
  #       volume_type = "gp2"
  #       volume_size = 10
  #       encrypted   = true
  #       kms_key_id  = aws_kms_key.this.arn
  #     }
  #   ]

  tags = {
    author      = "benone@sredevops.cloud"
    group       = "devops-admins"
    team        = "devops"
    project     = "TiendaNube"
    application = "eShop"
    cost-center = "CustomerName"
    environment = "staging"
  }
}

module "ec2-nginx" {
  source = "./modules/aws-ec2-instance/"

  instance_count = 1

  name                        = "web-server"
  ami                         = data.aws_ami.ubuntu_bionic.id
  instance_type               = "t2.micro"
  subnet_id                   = module.web-servers-vpc.public_subnets[1]
  private_ips                 = ["10.20.102.10"]
  vpc_security_group_ids      = [module.web_servers_sg.this_security_group_id]
  associate_public_ip_address = true
  key_name                    = "provisioning-key"

  user_data = "${data.template_file.nginx.rendered}"

  root_block_device = [
    {
      volume_type = "gp2"
      volume_size = 10
    },
  ]

  tags = {
    author      = "benone@sredevops.cloud"
    group       = "devops-admins"
    team        = "devops"
    project     = "TiendaNube"
    application = "eShop"
    cost-center = "CustomerName"
    environment = "staging"
  }
}

##################################################################
# ALB provisioning "No" ASG by - Modules
##################################################################

# module "log_bucket" {
#   source  = "terraform-aws-modules/s3-bucket/aws"
#   version = "~> 1.0"

#   bucket                         = "benone-logs-web-servers-alb"
#   acl                            = "log-delivery-write"
#   force_destroy                  = true
#   attach_elb_log_delivery_policy = true
# }

module "alb" {
  source = "./modules/aws-alb/"

  name = "web-servers-alb"

  load_balancer_type = "application"

  vpc_id          = module.web-servers-vpc.vpc_id
  subnets         = tolist(module.web-servers-vpc.public_subnets)
  security_groups = [module.alb_web_servers_sg.this_security_group_id]
  internal        = false

  # access_logs = {
  #   bucket = module.log_bucket.this_s3_bucket_id
  # }

  target_groups = [
    {
      name_prefix      = "web-"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "instance"
      slow_start       = "60"
    }
  ]

  #   https_listeners = [
  #     {
  #       port               = 443
  #       protocol           = "HTTPS"
  #       certificate_arn    = "arn:aws:iam::123456789012:server-certificate/test_cert-123456789012"
  #       target_group_index = 0
  #     }
  #   ]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
      action_type        = "forward"
    }
  ]

  tags = {
    environment = "module.ec2-nginx.id"
  }

}

##################################################################
# ALB provisioning by ASG - Modules
##################################################################

resource "aws_iam_service_linked_role" "autoscaling_1" {
  aws_service_name = "autoscaling.amazonaws.com"
  description      = "A service linked role for autoscaling"
  custom_suffix    = "web-server-1"

  # Sometimes good sleep is required to have some IAM resources created before they can be used
  provisioner "local-exec" {
    command = "sleep 10"
  }
}

resource "aws_iam_service_linked_role" "autoscaling_2" {
  aws_service_name = "autoscaling.amazonaws.com"
  description      = "A service linked role for autoscaling"
  custom_suffix    = "web-server-2"

  # Sometimes good sleep is required to have some IAM resources created before they can be used
  provisioner "local-exec" {
    command = "sleep 10"
  }
}

##################################################################
# Launch configuration and autoscaling group Apache
##################################################################
module "web-server-launch-asg-alb" {
  source = "./modules/aws-autoscaling/"

  name = "web-server-launch-asg-alb"

  # Launch configuration
  #
  # launch_configuration = "my-existing-launch-configuration" # Use the existing launch configuration
  # create_lc = false # disables creation of launch configuration
  lc_name = "web-server-apache-lc"

  image_id                     = data.aws_ami.ubuntu_bionic.id
  instance_type                = "t2.micro"
  security_groups              = [module.web_servers_sg.this_security_group_id]
  associate_public_ip_address  = true
  recreate_asg_when_lc_changes = true
  key_name                     = "provisioning-key"
  user_data                    = data.template_file.apache.rendered

  # ebs_block_device = [
  #   {
  #     device_name           = "/dev/xvdz"
  #     volume_type           = "gp2"
  #     volume_size           = "30"
  #     delete_on_termination = true
  #   },
  # ]

  root_block_device = [
    {
      volume_size           = "10"
      volume_type           = "gp2"
      delete_on_termination = true
    },
  ]

  # Auto scaling group
  asg_name                  = "web-servers-apache-asg"
  vpc_zone_identifier       = tolist(module.web-servers-vpc.public_subnets)
  health_check_grace_period = 300
  health_check_type         = "EC2"
  min_size                  = 1
  max_size                  = 1
  desired_capacity          = 1
  wait_for_capacity_timeout = 0
  service_linked_role_arn   = aws_iam_service_linked_role.autoscaling_1.arn
  target_group_arns         = tolist(module.alb.target_group_arns)

  tags = [
    {
      key                 = "environment"
      value               = "staging"
      propagate_at_launch = true
    },
    {
      key                 = "project"
      value               = "TiendaNube"
      propagate_at_launch = true
    },
    {
      key                 = "app"
      value               = "apache"
      propagate_at_launch = true
    },
  ]

  tags_as_map = {
    extra_tag1 = "extra_value1"
    extra_tag2 = "extra_value2"
  }
}

##################################################################
# Launch configuration and autoscaling group NGINX
##################################################################
module "web-server-nginx-launch-asg-alb" {
  source = "./modules/aws-autoscaling/"

  name = "web-server-nginx-launch-asg-alb"

  # Launch configuration
  #
  # launch_configuration = "my-existing-launch-configuration" # Use the existing launch configuration
  # create_lc = false # disables creation of launch configuration
  lc_name = "web-server-nginx-lc"

  image_id                     = data.aws_ami.ubuntu_bionic.id
  instance_type                = "t2.micro"
  security_groups              = [module.web_servers_sg.this_security_group_id]
  associate_public_ip_address  = true
  recreate_asg_when_lc_changes = true
  key_name                     = "provisioning-key"
  user_data                    = data.template_file.nginx.rendered

  # ebs_block_device = [
  #   {
  #     device_name           = "/dev/xvdz"
  #     volume_type           = "gp2"
  #     volume_size           = "30"
  #     delete_on_termination = true
  #   },
  # ]

  root_block_device = [
    {
      volume_size           = "10"
      volume_type           = "gp2"
      delete_on_termination = true
    },
  ]

  # Auto scaling group
  asg_name                  = "web-servers-nginx-asg"
  vpc_zone_identifier       = tolist(module.web-servers-vpc.public_subnets)
  health_check_grace_period = 300
  health_check_type         = "EC2"
  min_size                  = 1
  max_size                  = 1
  desired_capacity          = 1
  wait_for_capacity_timeout = 0
  service_linked_role_arn   = aws_iam_service_linked_role.autoscaling_2.arn
  target_group_arns         = tolist(module.alb.target_group_arns)

  tags = [
    {
      key                 = "environment"
      value               = "staging"
      propagate_at_launch = true
    },
    {
      key                 = "project"
      value               = "TiendaNube"
      propagate_at_launch = true
    },
    {
      key                 = "app"
      value               = "nginx"
      propagate_at_launch = true
    },
  ]

  tags_as_map = {
    extra_tag1 = "extra_value1"
    extra_tag2 = "extra_value2"
  }
}


##################################################################
# ALB provisioning by ASG - No Modules
##################################################################

resource "aws_iam_instance_profile" "web_server_profile_1" {
  name = "web_server_profile_1"
  role = aws_iam_role.web_server_role.name
}

resource "aws_iam_instance_profile" "web_server_profile_2" {
  name = "web_server_profile_2"
  role = aws_iam_role.web_server_role.name
}

resource "aws_iam_role" "web_server_role" {
  name = "web_server_role"
  path = "/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

resource "aws_launch_configuration" "web-server-apache" {
  name                 = "web-server-apache"
  depends_on           = [module.web_servers_sg.this_security_group_id, aws_iam_role.web_server_role]
  image_id             = data.aws_ami.ubuntu_bionic.id
  instance_type        = "t2.micro"
  iam_instance_profile = aws_iam_instance_profile.web_server_profile_1.id
  key_name             = "provisioning-key"
  security_groups      = [module.web_servers_sg.this_security_group_id]
  user_data            = data.template_file.apache.rendered
}

resource "aws_launch_configuration" "web-server-nginx" {
  name                 = "web-server-nginx"
  depends_on           = [module.web_servers_sg.this_security_group_id, aws_iam_role.web_server_role]
  image_id             = data.aws_ami.ubuntu_bionic.id
  instance_type        = "t2.micro"
  iam_instance_profile = aws_iam_instance_profile.web_server_profile_2.id
  key_name             = "provisioning-key"
  security_groups      = [module.web_servers_sg.this_security_group_id]
  user_data            = data.template_file.nginx.rendered
}

resource "aws_autoscaling_group" "web-server-asg" {
  name                      = "web-server-asg"
  depends_on                = [aws_launch_configuration.web-server-apache]
  vpc_zone_identifier       = tolist(module.web-servers-vpc.public_subnets)
  max_size                  = 1
  min_size                  = 1
  health_check_grace_period = 300
  health_check_type         = "EC2"
  desired_capacity          = 1
  force_delete              = true
  launch_configuration      = aws_launch_configuration.web-server-apache.id
  target_group_arns         = [aws_lb_target_group.web-server-TargetGroup.arn]
}

resource "aws_autoscaling_group" "web-server-nginx-asg" {
  name                      = "web-server-nginx-asg"
  depends_on                = [aws_launch_configuration.web-server-apache]
  vpc_zone_identifier       = tolist(module.web-servers-vpc.public_subnets)
  max_size                  = 1
  min_size                  = 1
  health_check_grace_period = 300
  health_check_type         = "EC2"
  desired_capacity          = 1
  force_delete              = true
  launch_configuration      = aws_launch_configuration.web-server-nginx.id
  target_group_arns         = [aws_lb_target_group.web-server-TargetGroup.arn]
}

##################################################################
# Second ALB provisioning to utilize with ASG - "No" Modules
##################################################################

resource "aws_lb" "web-server-alb" {
  name               = "web-server-alb"
  depends_on         = [aws_autoscaling_group.web-server-asg]
  subnets            = tolist(module.web-servers-vpc.public_subnets)
  internal           = false
  load_balancer_type = "application"
  security_groups    = [module.alb_web_servers_sg.this_security_group_id]

  tags = {
    Name        = "WebSrv"
    Environment = "Dev"
  }
}

resource "aws_lb_target_group" "web-server-TargetGroup" {
  name        = "web-server-TargetGroup"
  depends_on  = [module.web-servers-vpc.vpc_id]
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.web-servers-vpc.vpc_id
  target_type = "instance"

  health_check {
    interval            = 30
    path                = "/index.html"
    port                = 80
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 5
    protocol            = "HTTP"
    matcher             = "200,202"
  }
}

resource "aws_lb_listener" "web-server-Listener" {
  depends_on        = [aws_lb.web-server-alb, aws_lb_target_group.web-server-TargetGroup]
  load_balancer_arn = aws_lb.web-server-alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.web-server-TargetGroup.arn
    type             = "forward"
  }
}

##################################################################
# TODO! Add Cloudwatch basic monitoring, thresholds, and alarms
##################################################################