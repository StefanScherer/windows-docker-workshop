variable "admin_password" {
  description = "Windows Administrator password to login as."
  default = "Password1234!"
}

variable "key_name" {
  description = "Name of the SSH keypair to use in AWS."
  default = "terraform"
}

variable "aws_region" {
  description = "AWS region to launch servers."
  default = "eu-central-1"
}

# Microsoft Windows Server 2016 Base with Containers
variable "aws_amis" {
  default = {
    eu-central-1 = "ami-7fee2210"
  }
}
