###########################################
#            Knowledge Base Module        #
###########################################

variable "common_tags" {
  type        = map(string)
  description = "Common tags to be applied to the resources"

  validation {
    condition     = length(var.common_tags) > 0
    error_message = "common_tags debe contener al menos una etiqueta."
  }
}

variable "knowledgebases" {
  description = "Map of Knowledgebases to create"
  type = map(object({
    description                = optional(string, "Bedrock Knowledgebase")
    type                       = string
    storage_configuration_type = string
    vector_knowledge_base_configuration = optional(object({
      embedding_model_arn = string
      dimensions          = optional(number)
      embedding_data_type = optional(string)
    }))
    storage_configuration = optional(object({
      type = string
      opensearch_serverless_configuration = optional(object({
        collection_arn = string
        field_mapping = object({
          metadata_field = string
          text_field     = string
          vector_field   = string
        })
        vector_index_name = string
      }))
      pinecone_configuration = optional(object({
        connection_string      = string
        credentials_secret_arn = string
        field_mapping = object({
          metadata_field = string
          text_field     = string
        })
        namespace = optional(string)
      }))
      rds_configuration = optional(object({
        database_name          = string
        resource_arn           = string
        credentials_secret_arn = string
        table_name             = string
        field_mapping = object({
          metadata_field    = string
          primary_key_field = string
          text_field        = string
          vector_field      = string
        })
      }))
      redis_enterprise_cloud_configuration = optional(object({
        endpoint               = string
        credentials_secret_arn = string
        field_mapping = object({
          metadata_field = string
          text_field     = string
          vector_field   = string
        })
        vector_index_name = string
      }))
      s3_vectors_configuration = optional(object({
        index_arn         = optional(string)
        index_name        = optional(string)
        vector_bucket_arn = optional(string)
      }))
    }))
    data_sources = optional(map(object({
      description = string
      kms_key_arn = optional(string)
      vector_ingestion_configuration = optional(object({
        chunking_configuration = object({
          chunking_strategy = string
          fixed_size_chunking_configuration = optional(object({
            max_tokens         = number
            overlap_percentage = number
          }))
          hierarchical_chunking_configuration = optional(object({
            level_configurations = list(object({
              max_tokens = number
            }))
            overlap_tokens = number
          }))
          semantic_chunking_configuration = optional(object({
            breakpoint_percentile_threshold = number
            buffer_size                     = number
            max_token                       = number
          }))
        })
        custom_transformation_configuration = optional(object({
          s3_uri        = string
          step_to_apply = string
          lambda_arn    = string
        }))
        parsing_configuration = optional(object({
          parsing_strategy = string
          bedrock_foundation_model_configuration = optional(object({
            model_arn             = string
            parsing_modality      = optional(string)
            parsing_prompt_string = optional(string)
          }))
          bedrock_data_automation_configuration = optional(object({
            parsing_modality = optional(string)
          }))
        }))
      }))
      data_source_configuration = object({
        type = string
        s3_configuration = optional(object({
          bucket_arn              = string
          bucket_owner_account_id = optional(string)
          inclusion_prefixes      = optional(list(string))
        }))
        confluence_configuration = optional(object({
          auth_type              = string
          credentials_secret_arn = string
          host_type              = string
          host_url               = string
        }))
        salesforce_configuration = optional(object({
          auth_type              = string
          credentials_secret_arn = string
          host_url               = string
        }))
        share_point_configuration = optional(object({
          auth_type              = string
          credentials_secret_arn = string
          domain                 = string
          host_type              = string
          site_urls              = list(string)
          tenant_id              = string
        }))
        web_configuration = optional(object({
          seed_urls = optional(list(object({
            url = string
          })))
          crawler_configuration = optional(object({
            exclusion_filters = optional(list(string))
            inclusion_filters = optional(list(string))
            scope             = optional(string)
            crawler_limits = optional(object({
              max_pages  = optional(number)
              rate_limit = optional(number)
            }))
          }))
        }))
      })
    })))
    role_arn        = string
    additional_tags = optional(map(string), {})
  }))

  validation {
    condition     = length(var.knowledgebases) > 0
    error_message = "Debe definirse al menos un knowledge base."
  }
}

###########################################
#              Tag System                 #
###########################################

variable "client" {
  description = "Client name for resource naming and tagging"
  type        = string

  validation {
    condition     = length(var.client) > 0 && length(var.client) <= 10
    error_message = "client debe tener entre 1 y 10 caracteres."
  }
}

variable "project" {
  description = "Project name for resource naming and tagging"
  type        = string

  validation {
    condition     = length(var.project) > 0 && length(var.project) <= 15
    error_message = "project debe tener entre 1 y 15 caracteres."
  }
}

variable "environment" {
  description = "Environment name for resource naming and tagging"
  type        = string

  validation {
    condition     = contains(["dev", "qa", "pdn"], var.environment)
    error_message = "El entorno debe ser uno de: dev, qa, pdn."
  }
}