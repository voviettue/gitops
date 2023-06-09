terraform {
  required_version = "> 0.14"

  backend "s3" {
    bucket  = "gigapress-tfstate"
    key     = "default"
    region  = "eu-north-1"
    profile = "g"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.20.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.0.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.0.0"
    }
  }
}
