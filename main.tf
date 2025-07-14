#############################################
#         Bedrock Knowledge Base            #
# Developed with Amazon Q Developer support #
#############################################

resource "aws_bedrockagent_knowledge_base" "knowledge_bases" {
  provider = aws.project
  for_each = var.knowledgebases

  name        = "${var.client}-${var.project}-${var.environment}-${each.key}"
  description = each.value.description
  role_arn    = each.value.role_arn

  knowledge_base_configuration {
    type = each.value.type

    dynamic "vector_knowledge_base_configuration" {
      for_each = each.value.vector_knowledge_base_configuration != null ? [each.value.vector_knowledge_base_configuration] : []
      content {
        embedding_model_arn = vector_knowledge_base_configuration.value.embedding_model_arn
        dynamic "embedding_model_configuration" {
          for_each = vector_knowledge_base_configuration.value.dimensions != null ? [1] : []
          content {
            bedrock_embedding_model_configuration {
              dimensions = vector_knowledge_base_configuration.value.dimensions
            }
          }
        }
      }
    }
  }

  storage_configuration {
    type = each.value.storage_configuration_type

    dynamic "opensearch_serverless_configuration" {
      for_each = each.value.storage_configuration != null && each.value.storage_configuration.opensearch_serverless_configuration != null ? [each.value.storage_configuration.opensearch_serverless_configuration] : []
      content {
        collection_arn = opensearch_serverless_configuration.value.collection_arn
        field_mapping {
          metadata_field = opensearch_serverless_configuration.value.field_mapping.metadata_field
          text_field     = opensearch_serverless_configuration.value.field_mapping.text_field
          vector_field   = opensearch_serverless_configuration.value.field_mapping.vector_field
        }
        vector_index_name = opensearch_serverless_configuration.value.vector_index_name
      }
    }

    dynamic "pinecone_configuration" {
      for_each = each.value.storage_configuration != null && each.value.storage_configuration.pinecone_configuration != null ? [each.value.storage_configuration.pinecone_configuration] : []
      content {
        connection_string      = pinecone_configuration.value.connection_string
        credentials_secret_arn = pinecone_configuration.value.credentials_secret_arn
        field_mapping {
          metadata_field = pinecone_configuration.value.field_mapping.metadata_field
          text_field     = pinecone_configuration.value.field_mapping.text_field
        }
        namespace = pinecone_configuration.value.namespace
      }
    }

    dynamic "rds_configuration" {
      for_each = each.value.storage_configuration != null && each.value.storage_configuration.rds_configuration != null ? [each.value.storage_configuration.rds_configuration] : []
      content {
        database_name          = rds_configuration.value.database_name
        resource_arn           = rds_configuration.value.resource_arn
        credentials_secret_arn = rds_configuration.value.credentials_secret_arn
        table_name             = rds_configuration.value.table_name
        field_mapping {
          metadata_field    = rds_configuration.value.field_mapping.metadata_field
          primary_key_field = rds_configuration.value.field_mapping.primary_key_field
          text_field        = rds_configuration.value.field_mapping.text_field
          vector_field      = rds_configuration.value.field_mapping.vector_field
        }
      }
    }

    dynamic "redis_enterprise_cloud_configuration" {
      for_each = each.value.storage_configuration != null && each.value.storage_configuration.redis_enterprise_cloud_configuration != null ? [each.value.storage_configuration.redis_enterprise_cloud_configuration] : []
      content {
        endpoint               = redis_enterprise_cloud_configuration.value.database_name
        credentials_secret_arn = redis_enterprise_cloud_configuration.value.credentials_secret_arn
        field_mapping {
          metadata_field = redis_enterprise_cloud_configuration.value.field_mapping.metadata_field
          text_field     = redis_enterprise_cloud_configuration.value.field_mapping.text_field
          vector_field   = redis_enterprise_cloud_configuration.value.field_mapping.vector_field
        }
        vector_index_name = redis_enterprise_cloud_configuration.value.vector_index_name
      }
    }
  }

  tags = merge(
    var.common_tags,
    each.value.additional_tags,
    {
      Name = "${var.client}-${var.project}-${var.environment}-${each.key}"
    }
  )
}

###########################################
#         Bedrock Data Sources            #
###########################################
resource "aws_bedrockagent_data_source" "data_source" {
  provider = aws.project
  for_each = {
    for ds in local.data_sources : ds.ds_key => ds
  }

  knowledge_base_id = aws_bedrockagent_knowledge_base.knowledge_bases[each.value.kb_key].id
  name              = each.value.ds_config.name
  description       = each.value.ds_config.description

  data_source_configuration {
    type = each.value.ds_config.data_source_configuration.type

    dynamic "s3_configuration" {
      for_each = each.value.ds_config.data_source_configuration.s3_configuration != null ? [each.value.ds_config.data_source_configuration.s3_configuration] : []
      content {
        bucket_arn              = s3_configuration.value.bucket_arn
        bucket_owner_account_id = s3_configuration.value.bucket_owner_account_id
        inclusion_prefixes      = s3_configuration.value.inclusion_prefixes
      }
    }

    dynamic "confluence_configuration" {
      for_each = each.value.ds_config.data_source_configuration.confluence_configuration != null ? [each.value.ds_config.data_source_configuration.confluence_configuration] : []
      content {
        source_configuration {
          auth_type              = confluence_configuration.value.auth_type
          credentials_secret_arn = confluence_configuration.value.credentials_secret_arn
          host_type              = confluence_configuration.value.host_type
          host_url               = confluence_configuration.value.host_url
        }
      }
    }

    dynamic "salesforce_configuration" {
      for_each = each.value.ds_config.data_source_configuration.salesforce_configuration != null ? [each.value.ds_config.data_source_configuration.salesforce_configuration] : []
      content {
        source_configuration {
          auth_type              = salesforce_configuration.value.auth_type
          credentials_secret_arn = salesforce_configuration.value.credentials_secret_arn
          host_url               = salesforce_configuration.value.host_url
        }
      }
    }

    dynamic "share_point_configuration" {
      for_each = each.value.ds_config.data_source_configuration.share_point_configuration != null ? [each.value.ds_config.data_source_configuration.share_point_configuration] : []
      content {
        source_configuration {
          auth_type              = share_point_configuration.value.auth_type
          credentials_secret_arn = share_point_configuration.value.credentials_secret_arn
          domain                 = share_point_configuration.value.domain
          host_type              = share_point_configuration.value.host_type
          site_urls              = share_point_configuration.value.site_urls
          tenant_id              = share_point_configuration.value.tenant_id
        }
      }
    }

    dynamic "web_configuration" {
      for_each = each.value.ds_config.data_source_configuration.web_configuration != null ? [each.value.ds_config.data_source_configuration.web_configuration] : []
      content {
        source_configuration {
          url_configuration {
            dynamic "seed_urls" {
              for_each = web_configuration.value.seed_urls != null ? web_configuration.value.seed_urls : []
              content {
                url = seed_urls.value.url
              }
            }
          }
        }
        dynamic "crawler_configuration" {
          for_each = web_configuration.value.crawler_configuration != null ? [web_configuration.value.crawler_configuration] : []
          content {
            exclusion_filters = crawler_configuration.value.exclusion_filters
            inclusion_filters = crawler_configuration.value.inclusion_filters
            scope             = crawler_configuration.value.scope

            crawler_limits {
              rate_limit = crawler_configuration.value.crawler_limits.rate_limit
              max_pages  = crawler_configuration.value.crawler_limits.max_pages
            }
          }
        }
      }
    }
  }

  dynamic "vector_ingestion_configuration" {
    for_each = each.value.ds_config.vector_ingestion_configuration != null ? [each.value.ds_config.vector_ingestion_configuration] : []
    content {
      dynamic "chunking_configuration" {
        for_each = vector_ingestion_configuration.value.chunking_configuration != null ? [vector_ingestion_configuration.value.chunking_configuration] : []
        content {
          chunking_strategy = chunking_configuration.value.chunking_strategy

          dynamic "fixed_size_chunking_configuration" {
            for_each = chunking_configuration.value.fixed_size_chunking_configuration != null ? [chunking_configuration.value.fixed_size_chunking_configuration] : []
            content {
              max_tokens         = fixed_size_chunking_configuration.value.max_tokens
              overlap_percentage = fixed_size_chunking_configuration.value.overlap_percentage
            }
          }

          dynamic "hierarchical_chunking_configuration" {
            for_each = chunking_configuration.value.hierarchical_chunking_configuration != null ? [chunking_configuration.value.hierarchical_chunking_configuration] : []
            content {
              level_configuration {
                max_tokens = hierarchical_chunking_configuration.value.level_configuration.max_tokens
              }
              overlap_tokens = hierarchical_chunking_configuration.value.overlap_tokens
            }
          }

          dynamic "semantic_chunking_configuration" {
            for_each = chunking_configuration.value.semantic_chunking_configuration != null ? [chunking_configuration.value.semantic_chunking_configuration] : []
            content {
              breakpoint_percentile_threshold = semantic_chunking_configuration.value.breakpoint_percentile_threshold
              buffer_size                     = semantic_chunking_configuration.value.buffer_size
              max_token                       = semantic_chunking_configuration.value.max_token
            }
          }
        }
      }

      dynamic "custom_transformation_configuration" {
        for_each = vector_ingestion_configuration.value.custom_transformation_configuration != null ? [vector_ingestion_configuration.value.custom_transformation_configuration] : []
        content {
          intermediate_storage {
            s3_location {
              uri = custom_transformation_configuration.value.s3_uri
            }
          }
          transformation {
            step_to_apply = custom_transformation_configuration.value.step_to_apply
            transformation_function {
              transformation_lambda_configuration {
                lambda_arn = custom_transformation_configuration.value.lambda_arn
              }
            }
          }
        }
      }

      dynamic "parsing_configuration" {
        for_each = vector_ingestion_configuration.value.parsing_configuration != null ? [vector_ingestion_configuration.value.parsing_configuration] : []
        content {
          parsing_strategy = parsing_configuration.value.parsing_strategy
          bedrock_foundation_model_configuration {
            model_arn = parsing_configuration.value.model_arn
            parsing_prompt {
              parsing_prompt_string = parsing_configuration.value.parsing_prompt_string
            }
          }
        }
      }
    }
  }

  server_side_encryption_configuration {
    kms_key_arn = each.value.ds_config.kms_key_arn
  }

  lifecycle {
    replace_triggered_by = [
      aws_bedrockagent_knowledge_base.knowledge_bases
    ]
  }
}
