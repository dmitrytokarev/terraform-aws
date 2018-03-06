provider "aws" {
  region = "${var.aws_region}"
}


resource "aws_s3_bucket" "terraform_state" {
  bucket = "${var.s3_bucket_name}"

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = false
  }
}
