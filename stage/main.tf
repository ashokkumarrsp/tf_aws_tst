provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "${var.aws_region}"
}
module "frontend" {
  source = "../modules/frontend-app"
}
resource "aws_instance" "example" {
  ami = "ami-07b4156579ea1d7ba"
  instance_type = "t2.micro"
  vpc_security_group_ids = ["${module.frontend.sg_id}"]

  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p 8080 &
              EOF

  tags = {
    Name = "tf_aws_tst"
  }
  lifecycle {
    create_before_destroy = true
  }
}
output "public_ip" {
  value = "${module.frontend.elb_dns_name}"
}

