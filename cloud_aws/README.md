# Instruction on Cloud Tier

Commands to execute for each service:

```sh
cd autoscaling_elb/ 
terraform init 
terraform apply -target=aws_launch_template.web_server -auto-approve 
terraform apply -target=aws_autoscaling_group.asg -auto-approve 
terraform apply -target=aws_lb.web_elb -auto-approve

cd rds/
terraform init 
terraform apply -target=aws_db_instance.rds -auto-approve

cd dynamodb/
terraform init 
terraform apply -target=aws_dynamodb_table.intruder_logs -auto-approve

cd s3bucket/
terraform init 
terraform apply -target=aws_s3_bucket.intruder_images -auto-approve

cd iot_core/
terraform init 
terraform apply -target=aws_iot_topic_rule.intruder_alert -auto-approve

cd lambda/
terraform init 
terraform apply -target=aws_lambda_function.intruder_alert -auto-approve

cd security_grp/
terraform init 
terraform apply -target=aws_security_group.ec2_sg -auto-approve 
terraform apply -target=aws_security_group.rds_sg -auto-approve 
terraform apply -target=aws_security_group.elb_sg -auto-approve

cd aws_kinesis_video_stream/
terraform init 
terraform apply -target=aws_kinesis_video_stream.video_stream -auto-approve
