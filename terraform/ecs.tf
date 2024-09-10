resource "aws_ecs_cluster" "dev" {
  name = "dev"
}

resource "aws_security_group" "dev_app" {
  name   = "dev_app"
  vpc_id = aws_vpc.dev.id

  ingress {
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    self        = "false"
    cidr_blocks = ["172.32.0.0/16"]
    description = "traffic port from vpc"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_service" "service" {
  name            = "dev-app"
  cluster         = aws_ecs_cluster.dev.id
  task_definition = aws_ecs_task_definition.dev_app.arn
  desired_count   = "1"
  launch_type     = "FARGATE"
  network_configuration {
    security_groups = [aws_security_group.dev_app.id]
    subnets = [
      aws_subnet.dev_private_1.id,
      aws_subnet.dev_private_2.id
    ]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.dev_app.arn
    container_name   = "app"
    container_port   = "9000"
  }
}

##### Permissions used when starting container: Pull image, write logs, get secrets...
resource "aws_iam_role" "dev_app_exec_role" {
  name = "dev_app_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = "ecsAssume"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  ]
}

resource "aws_ecs_task_definition" "dev_app" {
  family                   = "dev-app"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.dev_app_exec_role.arn
  container_definitions = jsonencode([
    {
      name      = "app"
      essential = true
      image     = "${aws_ecr_repository.dev_app.repository_url}:latest"
      environment = [
        {
          "name" : "PORT",
          "value" : "9000"
        }
      ]
      portMappings = [
        {
          containerPort = 9000
          hostPort      = 9000
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "dev_app"
          "awslogs-stream-prefix" = "ecs"
          "awslogs-region"        = "eu-west-1"
        }
      }
    }
  ])
}

resource "aws_cloudwatch_log_group" "dev_app" {
  name              = "dev_app"
  retention_in_days = 30
}
