# Define provider
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

resource "aws_key_pair" "tf_key" {
  key_name   = "tf_key"
  public_key = tls_private_key.rsa.public_key_openssh
}

resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "tf_key" {
  content  = tls_private_key.rsa.private_key_pem
  filename = "tfkey"
}

/* data "aws_key_pair" "my_keypair_data" {
  key_name = aws_key_pair.my_keypair.key_name
} */

# Create EC2 instance
resource "aws_instance" "jenkins-master" {
  ami           = "ami-09cd747c78a9add63"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.tf_key.key_name
  vpc_security_group_ids = ["sg-0506020b0834bf49d"]
  associate_public_ip_address = true

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("tfkey")
    host        = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt install default-jdk -y",
      "java -version",
      "curl -fsSL https://pkg.jenkins.io/debian/jenkins.io.key | sudo tee",
                    "/usr/share/keyrings/jenkins-keyring.asc > /dev/null",
      "echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]",
                    "https://pkg.jenkins.io/debian binary/ | sudo tee",
                    "/etc/apt/sources.list.d/jenkins.list > /dev/null",
      "sudo apt-get update",
      "sudo apt-get install jenkins -y",
      "sudo systemctl start jenkins",
      "sudo cat /var/lib/jenkins/secrets/initialAdminPassword"
    ]
  }
}
  /* user_data =   <<-EOF
                #!/bin/bash

                sudo apt-get update
                sudo apt install default-jdk -y
                java -version

                curl -fsSL https://pkg.jenkins.io/debian/jenkins.io.key | sudo tee \
                    /usr/share/keyrings/jenkins-keyring.asc > /dev/null
                echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
                    https://pkg.jenkins.io/debian binary/ | sudo tee \
                    /etc/apt/sources.list.d/jenkins.list > /dev/null

                sudo apt-get update
                sudo apt-get install jenkins -y

                sudo systemctl start jenkins

                echo "Initial admin password:"
                sudo cat /var/lib/jenkins/secrets/initialAdminPassword
                EOF
} */

  /* connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("~/.ssh/id_rsa")
    host        = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y apache2",
      "sudo systemctl start apache2",
      "sudo systemctl enable apache2"
    ]
  }
} */

/* # Output key pair
output "key_pair" {
  value = data.aws_key_pair.my_keypair_data.key_name
} */

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.jenkins-master.public_ip
}

output "jenkins password" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.jenkins-master.remote-exec.baby
}


/* 
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("tfkey")
    host        = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y apache2",
      "sudo systemctl start apache2",
      "sudo systemctl enable apache2"
    ]
  }
} */
