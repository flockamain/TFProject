resource "aws_instance" "web" {
  ami                  = "ami-0b999ee292b09fdba"
  instance_type        = "t3.micro"
  vpc_security_group_ids = [aws_security_group.TF_SG.id]  # fixed
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
  user_data            = file("webserver.sh")
  key_name             = "ec2TF"

  tags = {
    Name = "terraformEC2"
  }
}

resource "aws_security_group" "TF_SG" {
    name = "Terraform Sec Grp"
    description = "Allow TLS traffic inbound"
    vpc_id = "vpc-0e7c4325751501184"


    ingress {
        description = "HTTPS"
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]

    }
    ingress {
        description = "SSH"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]

    }
    ingress {
        description = "HTTP"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }
    egress {
        description = "Allow all out"
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }

    tags = {
        Name = "TF_SG"
    }
}

resource "aws_iam_role" "ec2_s3_role" {
    name = "ec2_s3_access_role"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Action = "sts:AssumeRole"
            Effect = "Allow"
            Principal = {
                Service = "ec2.amazonaws.com"
            }
        }]
    })
}

resource "aws_iam_role_policy_attachment" "s3_access" {
    role = aws_iam_role.ec2_s3_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2_s3_profile"
  role = aws_iam_role.ec2_s3_role.name
}

resource "aws_lb_target_group" "main" {
  name     = "tf-web-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "vpc-0e7c4325751501184"

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "tf-web-tg"
  }
}

resource "aws_lb_target_group_attachment" "web" {
  target_group_arn = aws_lb_target_group.main.arn
  target_id        = aws_instance.web.id
  port             = 80
}

resource "aws_lb" "main" {
  name               = "tf-web-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.TF_SG.id]
  subnets            = [
    "subnet-01b5b54136d457fc3",  # us-east-2b
    "subnet-0a233f2cbc8057f93",  # us-east-2c
    "subnet-065bd37c9f80766b1"   # us-east-2a
  ]
  tags = {
    Name = "tf-web-alb"
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.main.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "arn:aws:acm:us-east-2:168455034552:certificate/48699543-e400-4c34-94cd-086326c71ac4"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}

resource "aws_lb_listener" "http_redirect" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}
data "aws_route53_zone" "main" {
  name = "wischalex.com"
}

resource "aws_route53_record" "website" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "website.wischalex.com"
  type    = "CNAME"
  ttl     = 300
  records = [aws_lb.main.dns_name]
}