# Instruction on Cloud Tier

Please follow the steps and user Terraform version 1.5.7
Commands to execute for each service:

```sh

## 1) IAM ROLES

cd iam_role/ec2
terraform init 
terraform plan -out ec2.out
terraform apply "ec2.out"

cd iam_role/grant
terraform init 
terraform plan -out grant.out
terraform apply "grant.out"

cd iam_role/iot
terraform init 
terraform plan -out iot.out
terraform apply "iot.out"

# cd iam_role/lambda
# terraform init 
# terraform plan -out lambda.out
# terraform apply "lambda.out"

# cd iam_role/raspberry
# terraform init 
# terraform plan -out raspberry.out
# terraform apply "raspberry.out"

## 2) Security Groups

cd security_grp/ec2_sg
terraform init 
terraform plan -out ec2_sg.out
terraform apply "ec2_sg.out"

cd security_grp/elb_sg
terraform init 
terraform plan -out elb_sg.out
terraform apply "elb_sg.out"

cd security_grp/rds_sg
terraform init 
terraform plan -out rds_sg.out
terraform apply "rds_sg.out"

## 3) RDS MySQL

cd rds/
terraform init 
terraform plan -out rds.out
terraform apply "rds.out"

## 4) DynamoDB

cd dynamodb/
terraform init 
terraform plan -out dynamodb.out
terraform apply "dynamodb.out"

## S3 bucket

cd s3bucket/
terraform init 
terraform plan -out s3bucket.out
terraform apply "s3bucket.out"

## 5) Lambda

cd lambda/
mkdir lambda_function
cd lambda_function
pip3 install requests -t .
pip3 install paho-mqtt -t .
cd lambda_function/
zip -r ../lambda_function.zip .
zip -r lambda_function.zip lambda_funciton.py
terraform init 
terraform plan -out lambda_funciton.out
terraform apply "lambda_funciton.out"

## 6) IoT Core

cd iot_core/
terraform init
terraform plan -out iot_core.out
Enter your AWS account number
terraform apply "iot_core.out"

## EC2 autosclaing ELB
cd autoscaling_elb/ 
terraform init 
terraform plan -out autoscaling_elb.out
terraform apply "autoscaling_elb.out"

## 7) AWS Kinesis (Optional)
cd aws_kinesis_video_stream/
terraform init 
terraform apply -target=aws_kinesis_video_stream.video_stream -auto-approve

## 8) EC2 Bastion host (Optional)
Setup Bastion host to access the rds and web-ec2 insatnces:
terraform init
terraform plan -out bastion_host.out
terraform apply "bastion_host.out"