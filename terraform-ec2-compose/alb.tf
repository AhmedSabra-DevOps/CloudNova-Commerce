data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.cloudnova_vpc.id
  cidr_block              = cidrsubnet(aws_vpc.cloudnova_vpc.cidr_block, 8, 2)
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true

  tags = {
    Name    = "cloudnova-public-subnet-2"
    Project = "CloudNova-Commerce"
  }
}

resource "aws_route_table_association" "public_assoc_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_security_group" "alb_sg" {
  name        = "cloudnova-alb-sg"
  description = "Allow HTTP traffic to CloudNova ALB"
  vpc_id      = aws_vpc.cloudnova_vpc.id

  ingress {
    description = "HTTP from Internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "cloudnova-alb-sg"
    Project = "CloudNova-Commerce"
  }
}

resource "aws_security_group_rule" "allow_http_from_alb_to_ec2" {
  type                     = "ingress"
  description              = "Allow HTTP from ALB to EC2"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = aws_security_group.cloudnova_sg.id
  source_security_group_id = aws_security_group.alb_sg.id
}

resource "aws_lb" "cloudnova_alb" {
  name               = "cloudnova-commerce-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]

  subnets = [
    aws_subnet.public_subnet.id,
    aws_subnet.public_subnet_2.id
  ]

  tags = {
    Name    = "cloudnova-commerce-alb"
    Project = "CloudNova-Commerce"
  }
}

resource "aws_lb_target_group" "cloudnova_tg" {
  name        = "cloudnova-commerce-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.cloudnova_vpc.id
  target_type = "instance"

  health_check {
    enabled             = true
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = {
    Name    = "cloudnova-commerce-tg"
    Project = "CloudNova-Commerce"
  }
}

resource "aws_lb_target_group_attachment" "cloudnova_ec2_attachment" {
  target_group_arn = aws_lb_target_group.cloudnova_tg.arn
  target_id        = aws_instance.cloudnova_demo.id
  port             = 80
}

resource "aws_lb_listener" "cloudnova_http_listener" {
  load_balancer_arn = aws_lb.cloudnova_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.cloudnova_tg.arn
  }
}

output "alb_dns_name" {
  value = aws_lb.cloudnova_alb.dns_name
}

output "alb_website_url" {
  value = "http://${aws_lb.cloudnova_alb.dns_name}"
}
