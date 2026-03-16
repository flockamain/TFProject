resource "aws_instance" "web" {
    ami = "ami-0b999ee292b09fdba"
    instance_type = "t3.micro"
    security_groups = [aws_security_group.TF_SG.name]
    iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
    user_data = file("webserver.sh")
    key_name = "ec2TF"

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
