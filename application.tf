data "aws_vpc" "existing" {
  tags = {
    Name = var.vpc_name
  }
}


data "aws_subnet" "public_a" {
  vpc_id     = data.aws_vpc.existing.id
  cidr_block = var.public_subnet_a_cidr
}

data "aws_subnet" "private_a" {
  vpc_id     = data.aws_vpc.existing.id
  cidr_block = var.private_subnet_a_cidr
}

data "aws_subnet" "public_b" {
  vpc_id     = data.aws_vpc.existing.id
  cidr_block = var.public_subnet_b_cidr
}

data "aws_subnet" "private_b" {
  vpc_id     = data.aws_vpc.existing.id
  cidr_block = var.private_subnet_b_cidr
}



data "aws_security_group" "ec2" {
  name   = var.ec2_security_group_name
  vpc_id = data.aws_vpc.existing.id
}

data "aws_security_group" "http" {
  name   = var.http_security_group_name
  vpc_id = data.aws_vpc.existing.id
}

data "aws_security_group" "load_balancer" {
  name   = var.load_balancer_security_group_name
  vpc_id = data.aws_vpc.existing.id
}



data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = var.ami_owners
  name_regex  = var.ami_name_regex
}



resource "aws_launch_template" "app" {
  name          = var.launch_template_name
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  key_name      = var.key_pair_name

  iam_instance_profile {
    name = var.instance_profile_name
  }

  network_interfaces {
    device_index                = 0
    delete_on_termination       = true
    associate_public_ip_address = true

    security_groups = [
      data.aws_security_group.ec2.id,
      data.aws_security_group.http.id
    ]
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "optional"
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash

    dnf update -y
    dnf install -y httpd jq

    systemctl enable httpd
    systemctl start httpd

    TOKEN=$(curl -sS -X PUT \
      "http://169.254.169.254/latest/api/token" \
      -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

    INSTANCE_ID=$(curl -sS \
      -H "X-aws-ec2-metadata-token: $TOKEN" \
      http://169.254.169.254/latest/meta-data/instance-id)

    PRIVATE_IP=$(curl -sS \
      -H "X-aws-ec2-metadata-token: $TOKEN" \
      http://169.254.169.254/latest/meta-data/local-ipv4)

    cat > /var/www/html/index.html <<HTML
    <html>
      <body>
        <h1>Terraform Application</h1>
        <p>Instance ID: $INSTANCE_ID</p>
        <p>Private IP: $PRIVATE_IP</p>
      </body>
    </html>
    HTML
  EOF
  )

  tags = {
    Terraform = "true"
    Project   = var.project_id
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Terraform = "true"
      Project   = var.project_id
    }
  }

  tag_specifications {
    resource_type = "volume"

    tags = {
      Terraform = "true"
      Project   = var.project_id
    }
  }
}



resource "aws_autoscaling_group" "app" {
  name = var.autoscaling_group_name

  desired_capacity = 2
  min_size         = 1
  max_size         = 2

  vpc_zone_identifier = [
    data.aws_subnet.public_a.id,
    data.aws_subnet.public_b.id
  ]

  health_check_type         = "ELB"
  health_check_grace_period = 120

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  tag {
    key                 = "Terraform"
    value               = "true"
    propagate_at_launch = true
  }

  tag {
    key                 = "Project"
    value               = var.project_id
    propagate_at_launch = true
  }

  lifecycle {
    ignore_changes = [
      load_balancers,
      target_group_arns
    ]
  }
}



resource "aws_lb_target_group" "app" {
  name     = var.target_group_name
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.existing.id

  health_check {
    enabled  = true
    path     = "/"
    protocol = "HTTP"
    matcher  = "200"
  }

  tags = {
    Terraform = "true"
    Project   = var.project_id
  }
}



resource "aws_lb" "app" {
  name               = var.load_balancer_name
  internal           = false
  load_balancer_type = "application"

  security_groups = [
    data.aws_security_group.load_balancer.id
  ]

  subnets = [
    data.aws_subnet.public_a.id,
    data.aws_subnet.public_b.id
  ]

  tags = {
    Terraform = "true"
    Project   = var.project_id
  }
}



resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}



resource "aws_autoscaling_attachment" "app" {
  autoscaling_group_name = aws_autoscaling_group.app.name
  lb_target_group_arn    = aws_lb_target_group.app.arn
}
