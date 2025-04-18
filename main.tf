terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  required_version = ">= 1.2.0"
}
resource "random_string" "hostname_prefix" {
  length  = 3
  upper   = false
  special = false
  number  = false
}

resource "random_integer" "hostname_suffix" {
  min = 100000
  max = 999999
}
locals {
  generated_hostname = "${random_string.hostname_prefix.result}${random_integer.hostname_suffix.result}"
}
resource "aws_security_group" "ssh_access" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
provider "aws" {
  region  = "ap-south-1"
  access_key = ""
  secret_key = ""
 }
resource "aws_instance" "web" {
  ami           = "ami-002f6e91abff6eb96"
  instance_type = "t2.micro"
  user_data = <<-EOF
              #!/bin/bash
              hostnamectl set-hostname ${local.generated_hostname}
              echo "127.0.0.1 ${local.generated_hostname}" >> /etc/hosts
              useradd -m raj
              echo "raj:VijayKrish123$" | chpasswd
              sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
              systemctl restart sshd
              EOF
  tags  = {
    Name  = "Rajesh"
  }
}
