# Instruction on Cloud Tier

Please follow the steps and user Terraform version 1.5.7
Commands to execute for each service:

```sh

## 1) IAM ROLES
cd iam_role/ec2
terraform init 
terraform plan -out ec2.out
terraform apply "ec2.out"

cd iam_role/iot
terraform init 
terraform plan -out iot.out
terraform apply "iot.out"

cd iam_role/lambda
terraform init 
terraform plan -out lambda.out
terraform apply "lambda.out"

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

## 7) EC2 autosclaing ELB
# Includes Java 17, Redis and Apache Web Server
# Please take note this process is only spinning of the instances with ASG and ALB. Th application is not installed into the instance. Please refer to the application folder to install the application and its configuration.
cd autoscaling_elb/ 
terraform init 
terraform plan -out autoscaling_elb.out
terraform apply "autoscaling_elb.out"

## 8) Amazon Managed Grafana
cd grafana/ 
terraform init 
terraform plan -out grafana.out
terraform apply "grafana.out"
Follow the steps in the link: https://docs.aws.amazon.com/grafana/latest/userguide/AMG-create-workspace.html
Videos:
https://www.youtube.com/watch?v=t3g17ye6drI
https://www.youtube.com/watch?v=KNRTY2_xQ3I

Step 1: Set Up AWS IAM Identity Center (SSO)
Amazon Managed Grafana uses AWS IAM Identity Center (formerly AWS SSO) for user authentication.
1)  Go to AWS IAM Identity Center Console:
    https://console.aws.amazon.com/singlesignon/
2)  Create a New User:
    - Go to Users → Add user
    - Fill in the user's email, username, and assign a password.
    - (Optional) Add them to a Group.

Step 2: Assign the User to the Grafana Workspace
1)  Go to the Amazon Managed Grafana Console:
    https://console.aws.amazon.com/grafana/
2)  Select your Grafana workspace.
3)  Click on "Assign new users and groups".
4)  Choose the IAM Identity Center user or group you created.
5)  Assign a role:
    - Admin: Full access
    - Editor: Can create/edit dashboards
    - Viewer: Read-only access

Step 3: User Logs In
1)  The user goes to the Grafana workspace URL provided in the console.
2)  Logs in with their IAM Identity Center credentials.

cd grafana/ 
terraform init 
terraform plan -out grafana.out
terraform apply "grafana.out"

Import the dashboards via the Grafana UI Page

## 9) EC2 Bastion host (Optional)
Setup Bastion host to access the rds and web-ec2 insatnces, however you can update the security policy to allow access to other resources from the EC2 instance you have brought up:
terraform init
terraform plan -out bastion_host.out
terraform apply "bastion_host.out"