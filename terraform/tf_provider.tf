provider "aws" {
  region = "eu-west-1"

  default_tags {
    tags = {
      repository = "github.com/theam/theam-devops-challenge"
      terraform  = "true"
      owner      = "devops-team"
      env        = "dev"
    }
  }
}
