# Bedrock Knowledge Base Module - Sample Configuration

# Knowledge Base Module
module "knowledge_base" {
  source = "../"
  providers = {
    aws.project = aws.principal
  }
  environment    = var.environment
  project        = var.project
  client         = var.client
  common_tags    = var.common_tags
  knowledgebases = var.knowledgebases
}
