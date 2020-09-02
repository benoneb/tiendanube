##########################################################
# VPC outputs
##########################################################

output "default_vpc_id" {
  description = "The ID of the VPC"
  value       = data.aws_vpc.default.id
}

output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.web-servers-vpc.vpc_id
}

## CIDR blocks
output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = module.web-servers-vpc.vpc_cidr_block
}

//output "vpc_ipv6_cidr_block" {
//  description = "The IPv6 CIDR block"
//  value       = ["${module.web-servers-vpc.vpc_ipv6_cidr_block}"]
//}

## Subnets
output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.web-servers-vpc.private_subnets
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = module.web-servers-vpc.public_subnets
}

## NAT gateways
output "nat_public_ips" {
  description = "List of public Elastic IPs created for AWS NAT Gateway"
  value       = module.web-servers-vpc.nat_public_ips
}

## AZs
output "azs" {
  description = "A list of availability zones spefified as argument to this module"
  value       = module.web-servers-vpc.azs
}

##########################################################
# Security Groups Outputs
##########################################################

output "this_security_group_id" {
  description = "The ID of the security group"
  value       = module.web_servers_sg.this_security_group_id
}

output "this_security_group_vpc_id" {
  description = "The VPC ID"
  value       = module.web_servers_sg.this_security_group_vpc_id
}

output "this_security_group_owner_id" {
  description = "The owner ID"
  value       = module.web_servers_sg.this_security_group_owner_id
}

output "this_security_group_name" {
  description = "The name of the security group"
  value       = module.web_servers_sg.this_security_group_name
}

output "this_security_group_description" {
  description = "The description of the security group"
  value       = module.web_servers_sg.this_security_group_description
}

output "canonical_user_id" {
  value = data.aws_canonical_user_id.current.id
}

##########################################################
# EC2 Outputs
##########################################################

output "ids" {
  description = "List of IDs of instances"
  value       = module.ec2-apache.id
}

output "public_dns" {
  description = "List of public DNS names assigned to the instances"
  value       = module.ec2-apache.public_dns
}

output "vpc_security_group_ids" {
  description = "List of VPC security group ids assigned to the instances"
  value       = module.ec2-apache.vpc_security_group_ids
}

output "root_block_device_volume_ids" {
  description = "List of volume IDs of root block devices of instances"
  value       = module.ec2-apache.root_block_device_volume_ids
}

output "ebs_block_device_volume_ids" {
  description = "List of volume IDs of EBS block devices of instances"
  value       = module.ec2-apache.ebs_block_device_volume_ids
}

output "tags" {
  description = "List of tags"
  value       = module.ec2-apache.tags
}

output "placement_group" {
  description = "List of placement group"
  value       = module.ec2-apache.placement_group
}

output "instance_id" {
  description = "EC2 instance ID"
  value       = module.ec2-apache.id
}

output "instance_public_dns" {
  description = "Public DNS name assigned to the EC2 instance"
  value       = module.ec2-apache.public_dns
}

output "credit_specification" {
  description = "Credit specification of EC2 instance (empty list for not t2 instance types)"
  value       = module.ec2-apache.credit_specification
}

output "ids_nginx" {
  description = "List of IDs of instances"
  value       = module.ec2-nginx.id
}

output "public_dns_nginx" {
  description = "List of public DNS names assigned to the instances"
  value       = module.ec2-nginx.public_dns
}

output "vpc_security_group_ids_nginx" {
  description = "List of VPC security group ids assigned to the instances"
  value       = module.ec2-nginx.vpc_security_group_ids
}

output "root_block_device_volume_ids_nginx" {
  description = "List of volume IDs of root block devices of instances"
  value       = module.ec2-nginx.root_block_device_volume_ids
}

output "ebs_block_device_volume_ids_nginx" {
  description = "List of volume IDs of EBS block devices of instances"
  value       = module.ec2-nginx.ebs_block_device_volume_ids
}

output "tags_nginx" {
  description = "List of tags"
  value       = module.ec2-nginx.tags
}

output "placement_group_nginx" {
  description = "List of placement group"
  value       = module.ec2-nginx.placement_group
}

output "instance_id_nginx" {
  description = "EC2 instance ID"
  value       = module.ec2-nginx.id
}

output "instance_public_dns_nginx" {
  description = "Public DNS name assigned to the EC2 instance"
  value       = module.ec2-nginx.public_dns
}

output "credit_specification_nginx" {
  description = "Credit specification of EC2 instance (empty list for not t2 instance types)"
  value       = module.ec2-nginx.credit_specification
}

##########################################################
# ALB Outputs
##########################################################

output "this_lb_id" {
  description = "The ID and ARN of the load balancer we created."
  value       = module.alb.this_lb_id
}

output "this_lb_arn" {
  description = "The ID and ARN of the load balancer we created."
  value       = module.alb.this_lb_arn
}

output "this_lb_dns_name" {
  description = "The DNS name of the load balancer."
  value       = module.alb.this_lb_dns_name
}

output "this_lb_arn_suffix" {
  description = "ARN suffix of our load balancer - can be used with CloudWatch."
  value       = module.alb.this_lb_arn_suffix
}

output "this_lb_zone_id" {
  description = "The zone_id of the load balancer to assist with creating DNS records."
  value       = module.alb.this_lb_zone_id
}

output "http_tcp_listener_arns" {
  description = "The ARN of the TCP and HTTP load balancer listeners created."
  value       = module.alb.http_tcp_listener_arns
}

output "http_tcp_listener_ids" {
  description = "The IDs of the TCP and HTTP load balancer listeners created."
  value       = module.alb.http_tcp_listener_ids
}

output "https_listener_arns" {
  description = "The ARNs of the HTTPS load balancer listeners created."
  value       = module.alb.https_listener_arns
}

output "https_listener_ids" {
  description = "The IDs of the load balancer listeners created."
  value       = module.alb.https_listener_ids
}

output "target_group_arns" {
  description = "ARNs of the target groups. Useful for passing to your Auto Scaling group."
  value       = module.alb.target_group_arns
}

output "target_group_arn_suffixes" {
  description = "ARN suffixes of our target groups - can be used with CloudWatch."
  value       = module.alb.target_group_arn_suffixes
}

output "target_group_names" {
  description = "Name of the target group. Useful for passing to your CodeDeploy Deployment Group."
  value       = module.alb.target_group_names
}

##########################################################
# LC and ASG Outputs
##########################################################

output "this_launch_configuration_id" {
  description = "The ID of the launch configuration"
  value       = module.web-server-launch-asg-alb.this_launch_configuration_id
}

output "this_autoscaling_group_id" {
  description = "The autoscaling group id"
  value       = module.web-server-launch-asg-alb.this_autoscaling_group_id
}

output "this_autoscaling_group_availability_zones" {
  description = "The availability zones of the autoscale group"
  value       = module.web-server-launch-asg-alb.this_autoscaling_group_availability_zones
}

output "this_autoscaling_group_vpc_zone_identifier" {
  description = "The VPC zone identifier"
  value       = module.web-server-launch-asg-alb.this_autoscaling_group_vpc_zone_identifier
}

output "this_autoscaling_group_load_balancers" {
  description = "The load balancer names associated with the autoscaling group"
  value       = module.web-server-launch-asg-alb.this_autoscaling_group_load_balancers
}

output "this_autoscaling_group_target_group_arns" {
  description = "List of Target Group ARNs that apply to this AutoScaling Group"
  value       = module.web-server-launch-asg-alb.this_autoscaling_group_target_group_arns
}