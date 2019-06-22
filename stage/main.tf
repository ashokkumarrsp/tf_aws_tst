provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "${var.aws_region}"
}

terraform {
backend "s3" {
bucket = "tf-bucket-vetrikootani"
dynamodb_table= "terraform-state-lock-dynamo"
region = "us-east-1"
key = "terraform.tfstate"
encrypt = "true"
}
}
module "frontend" {
  source = "../modules/frontend-app"
}
resource "aws_s3_bucket" "remotestate" {
  bucket = "tf-bucket-vetrikootani"
  acl    = "private"

  tags = {
    Name        = "tf state bucket vetrikootani"
    Environment = "Dev"
  }
  versioning {
    enabled = true
  }
}

# create a dynamodb table for locking the state file
resource "aws_dynamodb_table" "dynamodb-terraform-state-lock" {
name = "terraform-state-lock-dynamo"
hash_key = "LockID"
read_capacity = 20
write_capacity = 20
attribute {
name = "LockID"
type = "S"
}
tags = {
Name = "DynamoDB Terraform State Lock Table"
}
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

