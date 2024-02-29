variable "AWS_ACCESS_KEY_ID" {
  description = "AWS access key ID"
}
variable "AWS_SECRET_ACCESS_KEY" {
  description = "AWS secret access key"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  cloud {
    organization = "sun_devops"

    workspaces {
      name = "devops"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "eu-central-1"
}

# key
resource "tls_private_key" "ec2_key" {
  algorithm = "RSA"
  rsa_bits = 4096
}

output "private_key" {
  value = tls_private_key.ec2_key.private_key_pem
  sensitive = true
}

resource "tls_private_key" "github_actions_key" {
  algorithm   = "ED25519"
  ecdsa_curve = "P521"
}

output "github_actions_private_key" {
  value     = tls_private_key.github_actions_key.private_key_openssh
  sensitive = true
}

resource "aws_key_pair" "github_actions_key_pair" {
  key_name   = "github_actions-public-key"
  public_key = tls_private_key.github_actions_key.public_key_openssh
}

resource "aws_key_pair" "ec2_key_pair" {
  key_name = "ec2_key_name"
  public_key = tls_private_key.ec2_key.public_key_openssh
}

resource "aws_security_group" "ec2_security_group" {
  name = "ec2_security_group_sun"
  
  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  ingress {
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}

locals {
  env_content = file("${path.module}/.env")
  # creating lines for /etc/environment
  environment_values = [for line in split("\n", local.env_content) : 
                        line if line != "" && substr(line, 0, 1) != "#" ]
}

resource "aws_instance" "aws_ec2"{
    ami = "ami-0a23a9827c6dab833"
    instance_type = "t2.micro"
    key_name = aws_key_pair.ec2_key_pair.key_name
    security_groups = [aws_security_group.ec2_security_group.name]

    user_data = templatefile("${path.module}/install.sh", {
                    environment_lines = local.environment_values
                })

    tags = {
        Name = "sun-microservice-Instance"
  }
}

output "microservice_public_ip" {
  value = aws_instance.aws_ec2.public_ip
}

