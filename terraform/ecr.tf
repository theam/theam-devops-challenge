resource "aws_ecr_repository" "dev_app" {
  name = "dev_app"
  image_scanning_configuration {
    scan_on_push = true
  }
  tags = {
    Name = "dev app"
  }
}

resource "aws_ecr_lifecycle_policy" "dev_app" {
  repository = aws_ecr_repository.dev_app.name
  policy     = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Expire untagged after 1 day",
            "selection": {
                "tagStatus": "untagged",
                "countType": "sinceImagePushed",
                "countUnit": "days",
                "countNumber": 1
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}
