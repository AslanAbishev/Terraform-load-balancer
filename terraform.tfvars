aws_region = "eu-west-1"

project_id = "cmtr-7fdui0mc"

vpc_name = "cmtr-7fdui0mc-vpc"

public_subnet_a_cidr  = "10.0.1.0/24"
private_subnet_a_cidr = "10.0.2.0/24"
public_subnet_b_cidr  = "10.0.3.0/24"
private_subnet_b_cidr = "10.0.4.0/24"

ec2_security_group_name           = "cmtr-7fdui0mc-ec2_sg"
http_security_group_name          = "cmtr-7fdui0mc-http_sg"
load_balancer_security_group_name = "cmtr-7fdui0mc-sglb"

key_pair_name         = "cmtr-7fdui0mc-keypair"
instance_profile_name = "cmtr-7fdui0mc-instance_profile"

launch_template_name   = "cmtr-7fdui0mc-template"
autoscaling_group_name = "cmtr-7fdui0mc-asg"
load_balancer_name     = "cmtr-7fdui0mc-loadbalancer"
target_group_name      = "cmtr-7fdui0mc-tg"

instance_type = "t3.micro"

ami_name_regex = "^al2023-ami-2023.*-x86_64$"
ami_owners     = ["amazon"]
