resource "aws_security_group" "dev_alb" {
  name   = "dev_alb"
  vpc_id = aws_vpc.dev.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    self        = "false"
    cidr_blocks = ["0.0.0.0/0"]
    description = "http from internet"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "app_dev" {
  name               = "app-dev"
  load_balancer_type = "application"
  subnets = [
    aws_subnet.dev_public_1.id,
    aws_subnet.dev_public_2.id
  ]
  security_groups = [aws_security_group.dev_alb.id]
}
resource "aws_lb_listener" "app_dev" {
  load_balancer_arn = aws_lb.app_dev.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.dev_app.arn
  }
}

resource "aws_lb_target_group" "dev_app" {
  name                 = "dev-app"
  port                 = "9000"
  protocol             = "HTTP"
  vpc_id               = aws_vpc.dev.id
  target_type          = "ip"
  deregistration_delay = "10"
  health_check {
    path                = "/health"
    protocol            = "HTTP"
    interval            = 10
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}
