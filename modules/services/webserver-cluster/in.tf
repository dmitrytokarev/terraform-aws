variable "aws_region" {
  default = "us-west-2"
}

variable "server_port" {
  description = "The port the server will use for HTTP requests"
  default     = 8080
}

variable "ec2_instance_type" {
  default = "t2.micro"
}

variable "ec2_image_id" {
  default = "ami-c62eaabe"

  //  From: http://cloud-images.ubuntu.com/locator/ec2/
  //  ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-20180205 - ami-c62eaabe
  //  Canonical, Ubuntu, 16.04 LTS, amd64 xenial
  //  Image build on 2018-02-05
  //  Root device type: ebs
  //  Virtualization type: hvm
  //  ENA Enabled: Yes
}

variable "cluster_name" {
  description = "The name to use for all the cluster resources"
}

########################################################################
variable "db_remote_state_bucket" {
  description = "The name of the S3 bucket for the database's remote state"
}

variable "db_remote_state_key" {
  description = "The path for the database's remote state in S3"
}

variable "db_remote_state_region" {
  description = "The AWS region of Database state S3 bucket"
}
