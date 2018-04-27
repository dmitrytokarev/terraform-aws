# how to build graph https://github.com/hashicorp/terraform/issues/14511#issuecomment-366505121

provider "aws" {
  #  access_key = "ACCESS_KEY_HERE"  # TODO: read terraform docs about using aws creds
  #  secret_key = "SECRET_KEY_HERE"
  region = "${var.aws_region}"
}

//terraform {
//  backend "s3" {
//    bucket = "${var.db_remote_state_bucket}"
//    key    = "${var.db_remote_state_key}"
//    region = "${var.db_remote_state_region}"
//  }
//}

data "terraform_remote_state" "db" {
  backend = "s3"

  config {
    bucket = "${var.db_remote_state_bucket}"
    key    = "${var.db_remote_state_key}"
    region = "${var.db_remote_state_region}"
  }
}

data "template_file" "user_data" {
  template = "${file("${path.module}/user-data.sh")}"

  vars {
    server_port = "${var.server_port}"
    db_address  = "${data.terraform_remote_state.db.address}"
    db_port     = "${data.terraform_remote_state.db.port}"
  }
}

# Declare the data source
data "aws_availability_zones" "available" {}

resource "aws_launch_configuration" "example" {
  image_id        = "${var.ec2_image_id}"
  instance_type   = "${var.ec2_instance_type}"
  security_groups = ["${aws_security_group.example.id}"]

  user_data = "${data.template_file.user_data.rendered}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "example" {
  name = "${var.cluster_name}-instance"

  ingress {
    from_port   = "${var.server_port}"
    to_port     = "${var.server_port}"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "example" {
  launch_configuration = "${aws_launch_configuration.example.id}"
  availability_zones   = ["${data.aws_availability_zones.available.names}"]

  load_balancers    = ["${aws_elb.example.name}"]
  health_check_type = "ELB"

  min_size = 2
  max_size = 10

  tag {
    key                 = "Name"
    value               = "${var.cluster_name}-asg-example"
    propagate_at_launch = true
  }
}

resource "aws_elb" "example" {
  name               = "${var.cluster_name}-asg-example"
  availability_zones = ["${data.aws_availability_zones.available.names}"]
  security_groups    = ["${aws_security_group.elb.id}"]

  listener {
    lb_port           = 80
    lb_protocol       = "http"
    instance_port     = "${var.server_port}"
    instance_protocol = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    target              = "HTTP:${var.server_port}/"
  }
}

resource "aws_security_group" "elb" {
  name = "${var.cluster_name}-elb"

  ingress {
    from_port   = 80
    to_port     = 80
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
