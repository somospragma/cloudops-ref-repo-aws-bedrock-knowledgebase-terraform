# Bedrock Knowledge Base Module - Invocación del módulo padre
# PC-IAC-026: Solo invocar el módulo consumiendo valores de local.*

module "knowledge_base" {
  source = "../"

  providers = {
    aws.project = aws.principal
  }

  # Variables de gobernanza (PC-IAC-013)
  client      = var.client
  project     = var.project
  environment = var.environment
  common_tags = var.common_tags

  # Configuración transformada desde locals (PC-IAC-026)
  knowledgebases = local.knowledgebases_transformed
}
