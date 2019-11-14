provider "aws" {
  version = "~> 2.0"
  region  = "us-west-1"
}

# VPC
resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "JenkinsVPC"
  }
}

# Internet Gateway for VPC
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "JenkinsInternetGW"
  }
}

# Route table for VPC
resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.vpc.id

  # Route out to the world, at your peril
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "JenkinsRouteTable"
  }
}

# VPC Subnet
resource "aws_subnet" "subnet1" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "Subnet1"
  }
}

# Associate route table to subnet1
resource "aws_route_table_association" "route_association" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.route_table.id
}

# SECURITY GROUP
resource "aws_security_group" "web-server-sg" {
  name        = "WebServerSG"
  description = "Allow ssh (port 22) and http (port 8080)"

  # Apply security group to our custom VPC
  vpc_id = aws_vpc.vpc.id

  ingress {
    # ssh
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.web-server-sg-ingress-ssh-cidr_blocks
  }

  ingress {
    # http port 8080
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = var.web-server-sg-ingress-http-cidr_blocks
  }

  egress {
    #Allow
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # all
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# INSTANCES
resource "aws_key_pair" "key_pair" {
  key_name   = "deployer-key"
  public_key = var.public_key
}

resource "aws_instance" "jenkins" {
  ami                    = "ami-0bdb828fd58c52235"
  key_name               = "deployer-key"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.web-server-sg.id]
  subnet_id              = aws_subnet.subnet1.id

  associate_public_ip_address = true  #TODO dont expose like this
  source_dest_check           = false #To allow NAT or VPN access

  user_data = <<EOF
          #! /bin/bash
          sudo yum update -y
          sudo yum remove java -y
          sudo wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat/jenkins.repo
          sudo rpm --import https://pkg.jenkins.io/redhat/jenkins.io.key
          sudo yum install java-1.8.0-openjdk -y
          sudo yum install jenkins -y
          sudo service jenkins start

  EOF

  tags = {
    Name = "Jenkins"
  }
}

output "jenkins-instance-public-ip" {
  value = aws_instance.jenkins.public_ip
}
