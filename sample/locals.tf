# Bedrock Knowledge Base Module - Transformaciones del ejemplo
# PC-IAC-026: Todas las transformaciones e inyecciones dinámicas van aquí

locals {
  # Prefijo de gobernanza (PC-IAC-025)
  governance_prefix = "${var.client}-${var.project}-${var.environment}"

  # Transformar knowledgebases inyectando IDs dinámicos desde data sources (PC-IAC-009)
  knowledgebases_transformed = {
    for key, config in var.knowledgebases : key => merge(config, {
      # Inyectar role_arn desde data source si está vacío
      role_arn = length(config.role_arn) > 0 ? config.role_arn : data.aws_iam_role.kb_role.arn

      # Transformar storage_configuration inyectando collection_arn
      storage_configuration = config.storage_configuration != null ? merge(config.storage_configuration, {
        opensearch_serverless_configuration = config.storage_configuration.opensearch_serverless_configuration != null ? merge(
          config.storage_configuration.opensearch_serverless_configuration, {
            collection_arn = length(try(config.storage_configuration.opensearch_serverless_configuration.collection_arn, "")) > 0 ? config.storage_configuration.opensearch_serverless_configuration.collection_arn : data.aws_opensearchserverless_collection.kb_collection.arn
          }
        ) : null
      }) : null

      # Transformar data_sources inyectando bucket_arn y kms_key_arn
      data_sources = config.data_sources != null ? [
        for ds in config.data_sources : merge(ds, {
          kms_key_arn = length(try(ds.kms_key_arn, "")) > 0 ? ds.kms_key_arn : try(data.aws_kms_key.bedrock.arn, null)
          data_source_configuration = merge(ds.data_source_configuration, {
            s3_configuration = ds.data_source_configuration.s3_configuration != null ? merge(
              ds.data_source_configuration.s3_configuration, {
                bucket_arn = length(try(ds.data_source_configuration.s3_configuration.bucket_arn, "")) > 0 ? ds.data_source_configuration.s3_configuration.bucket_arn : data.aws_s3_bucket.kb_docs.arn
              }
            ) : null
          })
        })
      ] : null
    })
  }
}
