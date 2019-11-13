provider "aws" {
  version = "~> 2.0"
  region  = "us-west-1"
  profile = "default"
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

# VPC Subnet
resource "aws_subnet" "subnet1" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "Subnet1"
  }
}

# SECURITY GROUP
resource "aws_security_group" "web-server-sg" {
  name        = "WebServerSG"
  description = "Allow ssh (port 22) and http (port 8080)"

  ingress {
    # ssh
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] #TODO make configurable & safer
  }

  ingress {
    # http port 8080
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] #TODO make configurable & safer
  }
}

# INSTANCES

resource "aws_instance" "jenkins" {
  ami           = "ami-0bdb828fd58c52235"
  instance_type = "t2.micro"

  tags = {
    Name = "Jenkins"
  }
}
