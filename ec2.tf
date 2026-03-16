resource "aws_instance" "web" {
    ami = "ami-0b999ee292b09fdba"
    instance_type = "t3.micro"
    security_groups = [aws_security_group.TF_SG.name]

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
