#main.tf

/*
Name: Week21 Project -How to create AWS EC2 Auto-Scaling Group for High Availability using Terraform? 
Description: AWS Infrastructure Buildout with Terraform
Contributor: Jason Li
*/
/* This Terraform code is the main set of the configuration, we will use Terraform to create an autoscaling group that 
can automatically scale our EC2 instances up or down based on demand. Create a new VPC with a CIDR block and name.
Then create 2 public and 2 private subnets. The IP CIDR information is in the variables.tf file. This makes the file 
reusable. Use the data block in the providers.tf file to pull availability zone information for both sets of subnets.
Terraform's Infrastructure as code (IaC) to automate the creation and management of our AWS resources. This will 
allow us to spend less time managing infrastructure and more time to developing our applications.
*/


# Terraform Resources
#Create a new VPC in AWS

resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "TerraformVPC2023"
  }
}

#AWS Availability Zones
data "aws_availability_zones" "available" {
  state = "available"
}


# Security Group Resources
resource "aws_security_group" "alb_security_group" {
  name        = "${var.environment}-alb-security-group"
  description = "ALB Security Group"
  vpc_id      = aws_vpc.vpc.id
  ingress {
    description = "HTTP from Internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.environment}-alb-security-group"
  }
}
resource "aws_security_group" "asg_security_group" {
  name        = "${var.environment}-asg-security-group"
  description = "ASG Security Group"
  vpc_id      = aws_vpc.vpc.id
  ingress {
    description     = "HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_security_group.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.environment}-asg-security-group"
  }
}


/*Internet Gateway: a network device that allows traffic to flow between your VPC and the internet. 
It is a fundamental component of any VPC network.*/
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "Terraform2023_internet_gateway"
  }
}

#Creating 4Subnets, 2Private, 2public
/*The public subnet will have a public IP address assigned to each instance that is launched in it, while 
the private subnet will not. This allows you to control which instances are accessible from the 
internet and which are not.*/

#2Public Subnets
resource "aws_subnet" "public_subnet" {
  count                   = 2
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_subnet_cidr[count.index]
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = join("-", ["${var.environment}-public-subnet", data.aws_availability_zones.available.names[count.index]])
  }
}
#2Private Subnets
resource "aws_subnet" "private_subnet" {
  count             = 2
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.private_subnet_cidr[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = join("-", ["${var.environment}-private-subnet", data.aws_availability_zones.available.names[count.index]])
  }
}


/*Route table for public subnets, this ensures that all instances launched in 
public subnet will have access to the internet*/
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
  tags = {
    Name = "${var.environment}-public-route-table"
  }
}

#Elastic IP 
/*An EIP is a public IP address that can be assigned to an instance or load balancer. EIPs can be used to 
make your instances accessible from the internet.*/
resource "aws_eip" "elastic_ip" {
  tags = {
    Name = "${var.environment}-elastic-ip"
  }
}


#AWS NAT Gateway:  
/*is a network device that allows instances in a private subnet to access the internet. 
It does this by translating the private IP addresses of the instances to public IP addresses.*/
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.elastic_ip.id
  subnet_id     = aws_subnet.public_subnet[0].id
  depends_on    = [aws_internet_gateway.internet_gateway]
  tags = {
    Name = "Terraform2023InternetGateway"
  }
}


# Application Load Balancer Resources
/*Creates an Application Load Balancer (ALB) that is accessible from the internet, uses the application load balancer 
type, and uses the ALB security group. The ALB will be created in all public subnets.*/
resource "aws_lb" "alb" {
  name               = "${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_security_group.id]
  subnets            = [for i in aws_subnet.public_subnet : i.id]
}

#creating a target group that listens on port 80 and uses the HTTP protocol. 
resource "aws_lb_target_group" "target_group" {
  name     = "${var.environment}-tgrp"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id
  health_check {
    path    = "/"
    matcher = 200
  }
}

#Application Load Balancer: Is a powerful tool that can help you improve the performance, security, and 
#availability of your applications
/*Creating a listener that listens on port 80 and uses the HTTP protocol. The listener will be associated 
with the application load balancer*/
resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
  tags = {
    Name = "${var.environment}-alb-listenter"
  }
}

#AutoScalingGroup 
/*if the number of requests to the target groups increases, the Auto Scaling group will automatically scale the number 
of instances in the group up to handle the increased load. If the number of requests to the target groups decreases, 
the Auto Scaling group will automatically scale the number of instances in the group down to save costs.*/
resource "aws_autoscaling_group" "auto_scaling_group" {
  name = "my-autoscaling-group"
  desired_capacity = 2
  max_size = 5
  min_size = 2
  vpc_zone_identifier = flatten([
    aws_subnet.private_subnet.*.id,
  ])
  target_group_arns = [
    aws_lb_target_group.target_group.arn,
  ]
  launch_template {
    id = aws_launch_template.launch_template.id
    version = aws_launch_template.launch_template.latest_version
  }
}


#AWS Route-Table:  A route table is a collection of routes that determines how traffic is routed within a VPC. 
/*In this case, the route table will route all traffic to the NAT gateway, which will then forward the traffic 
to the internet.*/
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }
  tags = {
    Name = "${var.environment}-private-route-table"
  }
}

#Create two route table associations, one for the public subnet and one for the private subnet.
#public subnet will be associated with the public route table
resource "aws_route_table_association" "public_rt_assoc" {
  count          = 2
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}
#Private subnet will be associated with the private route table
resource "aws_route_table_association" "private_rt_assoc" {
  count          = 2
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_route_table.id
}
/*This will ensure that instances in the public subnet can access the internet, and instances in the 
private subnet can only access resources within the VPC.*/


# Lookup Ubunut AMI Image
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-gp2"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

# Launch Template and ASG Resources
resource "aws_launch_template" "launch_template" {
  name          = "${var.environment}-launch-template"
  image_id      = data.aws_ami.amzlinux2.id
  instance_type = var.instance_type
  network_interfaces {
    device_index    = 0
    security_groups = [aws_security_group.asg_security_group.id]
  }
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.environment}-asg-ec2"
    }
  }
  user_data = filebase64("${path.module}/app1.sh")
}


#variables.tf


/*EC2 variables can be used to store values such as the AMI ID, instance type, and VPC ID of an 
EC2 instance. These values in our Terraform code are used to create and configure EC2 instances. */

variable "ami" {
  description = "ami of ec2 instance"
  type        = string
  default     = "ami-0715c1897453cabd1"
}

# Launch Template and ASG Variables
variable "instance_type" {
  description = "launch template EC2 instance type"
  type        = string
  default     = "t2.micro"
}


#This user data variable indicates that the script configures Apache on a server.
variable "ec2_user_data" {
  description = "variable indicates that the script configures Apache on a server"
  type        = string
  default     = <<EOF
#!/bin/bash
# Install Apache on Ubuntu
sudo yum update -y
sudo yum install -y httpd
sudo cat > /var/www/html/index.html << EOF
<html>
<head>
  <title> Apache 2023 Terraform </title>
</head>
<body>
  <p> Welcome to Jason's Apache WebPage powered by AWS EC2 Auto-Scaling Group using Terraform!
</body>
</html>
EOF
}


/*This VPC can then be used to deploy resources that need to be accessible from the internet or from other resources in the VPC.
This variable defines the CIDR block for the VPC. The default value is 10.0.0.0/16.
*/

# VPC Variables
variable "vpc_cidr" {
  description = "VPC cidr block"
  type        = string
  default     = "10.10.0.0/16"
}

#These Public subnets are used for resources that need to be accessible from the internet
variable "public_subnet_cidr" {
  description = "Public Subnet cidr block"
  type        = list(string)
  default     = ["10.10.0.0/24", "10.10.2.0/24"]
}

#These Private subnets can be used to deploy resources that do not need to be accessible from the internet.
variable "private_subnet_cidr" {
  description = "Private Subnet cidr block"
  type        = list(string)
  default     = ["10.10.3.0/24", "10.10.4.0/24"]
}

#This is a Environement variable 
variable "environment" {
  description = "Environment name for deployment"
  type        = string
  default     = "week21terraformEnvironment"
}

# This is a Region Variable
variable "aws_region" {
  description = "AWS region name"
  type        = string
  default     = "us-east-1"
}


#providers.tf

# Terraform Providers
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      #version = "~> 4.0"
    }
  }
}
provider "aws" {
  region = "us-east-1"
}

#outputs.tf
/*This code defines an output called alb_public_url with the description "Public URL for Application Load Balancer" 
and the value of the DNS name of the Application Load Balancer. This output can be used to get the public URL of the 
Application Load Balancer after Terraform has been applied. */
# Terraform Outputs
output "alb_public_url" {
  description = "Public URL for Application Load Balancer"
  value       = aws_lb.alb.dns_name
}
