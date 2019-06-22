output "elb_dns_name" {
  value = "${aws_elb.example.dns_name}"
}

output "sg_id" {
  value = "${aws_security_group.instance.id}"
}