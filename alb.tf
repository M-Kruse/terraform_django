# security group for application load balancer
resource "aws_security_group" "django-app_alb_sg" {
  name        = "django-app-alb-sg"
  description = "allow incoming HTTP traffic only"
  vpc_id      = "${aws_vpc.django-app.id}"

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "alb-security-group-django-app"
  }
}

# using ALB - instances in private subnets
resource "aws_alb" "django-app-resume-dev-alb" {
  name                      = "django-app-resume-dev-alb"
  security_groups           = [aws_security_group.django-app_alb_sg.id]
  subnets                   = aws_subnet.private.*.id
  tags = {
    Name = "django-app-alb"
  }
}

# alb target group
resource "aws_alb_target_group" "django-app-resume-tg" {
  name     = "django-app-resume-dev-alb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.django-app.id}"
  health_check {
    path = "/"
    port = 80
  }
}

# listener
resource "aws_alb_listener" "http_listener" {
  load_balancer_arn = "${aws_alb.django-app-resume-dev-alb.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.django-app-resume-tg.arn}"
    type             = "forward"
  }
}

# target group attach
# using nested interpolation functions and the count parameter to the "aws_alb_target_group_attachment"
resource "aws_lb_target_group_attachment" "django-app" {
  count            = "${length(var.azs)}"
  target_group_arn = "${aws_alb_target_group.django-app-resume-tg.arn}"
  target_id        =  "${element(split(",", join(",", aws_instance.django-app.*.id)), count.index)}"
  port             = 80
}

# ALB DNS is generated dynamically, return URL so that it can be used
output "url" {
  value = "http://${aws_alb.django-app-resume-dev-alb.dns_name}/"
}
