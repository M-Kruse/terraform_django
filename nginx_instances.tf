# EC2 instances, one per availability zone
resource "aws_instance" "django-app" {
  ami                         = "${lookup(var.ec2_amis, var.aws_region)}"
  associate_public_ip_address = true
  count                       = "${length(var.azs)}"
  depends_on                  = ["aws_subnet.private"]
  instance_type               = "t2.micro"
  subnet_id                   = "${element(aws_subnet.private.*.id,count.index)}"
  user_data                   = "${file("user_data.sh")}"
  key_name                    = var.ami_key_pair_name

  # references security group created above
  vpc_security_group_ids = ["${aws_security_group.django-app.id}"]

  tags = {
    Name = "django-app-instance-${count.index}"
  }
}

# security group for django
resource "aws_security_group" "django-app" {
  name        = "django-app"
  description = "allow incoming HTTP traffic only"
  vpc_id      = "${aws_vpc.django-app.id}"

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}