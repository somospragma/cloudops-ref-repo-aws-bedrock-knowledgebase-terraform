# Bedrock Knowledge Base Module - Data Sources del ejemplo

# Current AWS region
data "aws_region" "current" {
  provider = aws.principal
}

# Current AWS caller identity
data "aws_caller_identity" "current" {
  provider = aws.principal
}

data "aws_partition" "current" {
  provider = aws.principal
}

# Obtener rol IAM para Knowledge Base por nomenclatura estándar (PC-IAC-017)
data "aws_iam_role" "kb_role" {
  provider = aws.principal
  name     = "${var.client}-${var.project}-${var.environment}-role-bedrock-kb"
}

# Obtener colección OpenSearch Serverless por tags (PC-IAC-017)
data "aws_opensearchserverless_collection" "kb_collection" {
  provider = aws.principal
  name     = "${var.client}-${var.project}-${var.environment}-aoss-kb"
}

# Obtener bucket S3 de documentos por nomenclatura estándar
data "aws_s3_bucket" "kb_docs" {
  provider = aws.principal
  bucket   = "${var.client}-${var.project}-${var.environment}-s3-kb-docs"
}

# Obtener KMS key para cifrado
data "aws_kms_key" "bedrock" {
  provider = aws.principal
  key_id   = "alias/${var.client}-${var.project}-${var.environment}-kms-bedrock"
}
