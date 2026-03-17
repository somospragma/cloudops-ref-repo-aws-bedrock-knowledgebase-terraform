###########################################
# Requisitos de versión de Terraform y Providers
###########################################

terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = ">= 5.0.0"
      configuration_aliases = [aws.project]
    }
  }
}
