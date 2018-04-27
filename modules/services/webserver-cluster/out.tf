output "elb_data" {
  value = {
    elb_id         = "${aws_elb.example.id}"
    elb_name       = "${aws_elb.example.name}"
    elb_public_dns = "${aws_elb.example.dns_name}"
  }
}
