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
  region = "us-east-2"
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
  filename = "tf_key"
}

/* data "aws_key_pair" "my_keypair_data" {
  key_name = aws_key_pair.my_keypair.key_name
} */

# Create EC2 instance
resource "aws_instance" "jenkins-master" {
  ami           = "ami-06c4532923d4ba1ec"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.tf_key.key_name
  vpc_security_group_ids = ["sg-03c0e5a4cc3d431eb"]
  associate_public_ip_address = true
}

resource "null_resource" "name" {

  # ssh into the ec2 instance
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = local_file.tf_key.content
    host        = aws_instance.jenkins-master.public_ip
  }

  # copy the install_jenkins.sh file from your computer to the ec2 instance
  provisioner "file" {
    source      = "installjenkins.sh"
    destination = "/tmp/installjenkins.sh"
  }

  # set permissions and run the install_jenkins.sh file
  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /tmp/installjenkins.sh",
      "sh /tmp/installjenkins.sh",
    ]
  }

  # wait for ec2 to be created
  depends_on = [aws_instance.jenkins-master]
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.jenkins-master.public_ip
}
