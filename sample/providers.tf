# Bedrock Knowledge Base Module - Configuración de providers

provider "aws" {
  region  = var.aws_region
  alias   = "principal"
  profile = var.profile

  default_tags {
    tags = var.common_tags
  }
}

terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
  }
}
