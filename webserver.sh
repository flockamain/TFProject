#!/bin/bash
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd

# Install AWS CLI (if not already present)
yum install -y awscli

# Pull your files from S3 into Apache's web root
aws s3 cp s3://s3bucketforwebserver-flockamain/personal-website/ /var/www/html/ --recursive