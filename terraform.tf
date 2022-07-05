terraform {
    required_providers {
      aws = {
        source  = "hashicorp/aws"
        version = "~> 3.0"
      }
    }
  }
  
  # Configure the AWS Provider
  provider "aws" {
    region = "ap-south-1"
  }
  
  resource "aws_vpc" "myvpc" {
    cidr_block       = "10.0.0.0/16"
    instance_tenancy = "default"
  
    tags = {
      Name = "myvpc"
    }
  }
  
  resource "aws_subnet" "pubsubnt" {
    vpc_id     = aws_vpc.myvpc.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "ap-south-1a"
  
    tags = {
      Name = "public subnet"
    }
  }
  
  resource "aws_internet_gateway" "tigw" {
    vpc_id = aws_vpc.myvpc.id
  
    tags = {
      Name = "terraform internetgw"
    }
  }
  
  resource "aws_route_table" "pubrt" {
      vpc_id = aws_vpc.myvpc.id
    
      route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.tigw.id
      }
    
      tags = {
        Name = "public rt"
      }
    }
  
    resource "aws_route_table_association" "pubasso" {
      subnet_id      = aws_subnet.pubsubnt.id
      route_table_id = aws_route_table.pubrt.id
    }
  
    resource "aws_security_group" "publicsg" {
      name        = "publicsg"
      description = "Allow TLS inbound traffic"
      vpc_id      = aws_vpc.myvpc.id
    
      ingress {
        description      = "TLS from VPC"
        from_port        = 0
        to_port          = 65535
        protocol         = "tcp"
        cidr_blocks      = ["0.0.0.0/0"]
      }
   
      egress {
        from_port        = 0
        to_port          = 0
        protocol         = "-1"
        cidr_blocks      = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
      }
    
      tags = {
        Name = "public security grp"
      }
    }
  
    resource "aws_instance" "pub_instance" {
      ami                                                     = "ami-079b5e5b3971bd10d"
      instance_type                                   = "t2.micro"
      availability_zone                              = "ap-south-1a"
      associate_public_ip_address         = "true"
      vpc_security_group_ids                 = [aws_security_group.publicsg.id]
      subnet_id                                          = aws_subnet.pubsubnt.id 
      key_name                                         = "ADHAVAN"
      
        tags = {
        Name = "JENKINS-iaac"
      }
    }
    
  