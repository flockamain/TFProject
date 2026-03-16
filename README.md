***Type “aws configure” into bash before any of this!! You want to confirm that this will be built in your own aws account***

Install terraform using homebrew or whatever you would do based on your OS

Create a file in your terraform project folder

cd to the terraform folder
-type “terraform init” in bash

***If something already exists with the same configs, but something can just be changed - it will just adjust the current resource***
***i.e. - changed tags = { Name = "terraformEC2” } when an ec2 instance with the same settings existed within aws. It just changed the name***

commands before launching:
terraform validate

terraform plan

terraform apply
