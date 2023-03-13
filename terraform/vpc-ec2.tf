terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

# Create a VPC
resource "aws_vpc" "myvpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "MY-VPC"
  }
}

resource "aws_subnet" "pubsub" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "MY-VPC-PUB-SUB"
  }
}

resource "aws_subnet" "prisub" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "MY-VPC-PRI-SUB"
  }
}

resource "aws_internet_gateway" "tigw" {
  vpc_id = aws_vpc.myvpc.id

  tags = {
    Name = "MY-VPC-IGW"
  }
}

resource "aws_route_table" "pubrt" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tigw.id
  }

  tags = {
    Name = "MY-VPC-PUB-RT"
  }
}

resource "aws_route_table_association" "pubrtassc" {
  subnet_id      = aws_subnet.pubsub.id
  route_table_id = aws_route_table.pubrt.id
}

resource "aws_eip" "myteip" {
  #instance = aws_instance.web.id
  vpc      = true
}

resource "aws_nat_gateway" "tngw" {
  allocation_id = aws_eip.myteip.id
  subnet_id     = aws_subnet.pubsub.id

  tags = {
    Name = "gw NAT"
  }
}

resource "aws_route_table" "prirt" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.tngw.id
  }

  tags = {
    Name = "MY-VPC-PRI-RT"
  }
}

resource "aws_route_table_association" "prirtassc" {
  subnet_id      = aws_subnet.prisub.id
  route_table_id = aws_route_table.prirt.id
}

resource "aws_security_group" "allow_all" {
  name        = "allow_all"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.myvpc.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 22
    to_port          = 22
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
    Name = "MY-VPC-SG"
  }
}

/* resource "aws_key_pair" "my-jenkins-tf" {
  key_name   = "my-jenkins-tf"
  public_key = "${file("~/.ssh/my-key-pair.pub")}"
} */

# Create EC2 instance
resource "aws_instance" "jenkins-master" {
  ami           = "ami-09cd747c78a9add63"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.pubsub.id
  key_name      = "jenkins-master"
  vpc_security_group_ids = [aws_security_group.allow_all.id]
  associate_public_ip_address = true
}

resource "aws_instance" "jenkins-slave" {
  ami           = "ami-09cd747c78a9add63"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.prisub.id
  key_name      = "jenkins-master"
  vpc_security_group_ids = [aws_security_group.allow_all.id]
}