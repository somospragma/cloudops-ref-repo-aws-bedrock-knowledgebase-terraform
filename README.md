# Módulo Terraform: bedrock-knowledge-base

## Descripción

Este módulo gestiona la creación y configuración de Knowledge Bases en AWS Bedrock con soporte para múltiples tipos de fuentes de datos. Proporciona una interfaz unificada para desplegar bases de conocimiento con diferentes configuraciones de almacenamiento vectorial y capacidades de ingesta de datos.

Para más detalles sobre los cambios y versiones, consulte el [CHANGELOG.md](./CHANGELOG.md).

## Características

- Soporte para múltiples backends de almacenamiento vectorial:
  - Amazon OpenSearch Serverless
  - Pinecone
  - Amazon RDS (PostgreSQL con pgvector)
  - Redis Enterprise Cloud
  - Amazon S3 Vectors
- Configuración flexible de fuentes de datos (S3, Confluence, Salesforce, SharePoint, Web)
- Configuración de ingesta vectorial con estrategias de chunking (Fixed Size, Hierarchical, Semantic)
- Soporte para parsing con modelos de Bedrock Foundation
- Transformaciones personalizadas con Lambda
- Cifrado server-side con KMS para data sources
- Sistema de etiquetado consistente con `common_tags` y `additional_tags`

## Estructura del Módulo

```
bedrock-knowledge-base/
├── .gitignore
├── CHANGELOG.md
├── README.md
├── data.tf
├── locals.tf
├── main.tf
├── outputs.tf
├── providers.tf
├── variables.tf
├── versions.tf
└── sample/
    ├── README.md
    ├── data.tf
    ├── locals.tf
    ├── main.tf
    ├── outputs.tf
    ├── providers.tf
    ├── terraform.tfvars
    └── variables.tf
```

## Requisitos Técnicos

- **Terraform**: >= 1.0
- **Provider AWS**: >= 5.0.0

## Convenciones de Nomenclatura (PC-IAC-003)

Los recursos creados siguen la convención:

```
{client}-{project}-{environment}-kb-{knowledge-base-key}
```

Ejemplo: `pragma-genai-dev-kb-documentation`

La nomenclatura se construye de forma centralizada en `locals.tf` mediante el `governance_prefix`.

## Recursos Gestionados

| Recurso | Descripción |
|---------|-------------|
| `aws_bedrockagent_knowledge_base` | Knowledge Bases en Bedrock |
| `aws_bedrockagent_data_source` | Fuentes de datos para Knowledge Bases |

## Parámetros de Entrada

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| knowledgebases | Mapa de configuración de Knowledge Bases | `map(object({...}))` | n/a | yes |
| client | Nombre del cliente (max 10 chars) | `string` | n/a | yes |
| project | Nombre del proyecto (max 15 chars) | `string` | n/a | yes |
| environment | Entorno de despliegue (dev, qa, pdn) | `string` | n/a | yes |
| common_tags | Tags comunes para todos los recursos | `map(string)` | n/a | yes |

### Estructura de `knowledgebases`

```hcl
knowledgebases = map(object({
  description                = optional(string, "Bedrock Knowledgebase")
  type                       = string           # "VECTOR", "KENDRA", "SQL"
  storage_configuration_type = string           # "OPENSEARCH_SERVERLESS", "PINECONE", "RDS", "REDIS_ENTERPRISE_CLOUD", "S3_VECTORS"
  role_arn                   = string           # ARN del rol IAM para el KB
  additional_tags            = optional(map(string), {})

  vector_knowledge_base_configuration = optional(object({
    embedding_model_arn = string                # ARN del modelo de embeddings
    dimensions          = optional(number)      # Dimensiones del vector
    embedding_data_type = optional(string)      # "FLOAT32" o "BINARY"
  }))

  storage_configuration = optional(object({
    type = string

    # Opción 1: OpenSearch Serverless
    opensearch_serverless_configuration = optional(object({
      collection_arn    = string
      vector_index_name = string
      field_mapping = object({
        metadata_field = string
        text_field     = string
        vector_field   = string
      })
    }))

    # Opción 2: Pinecone
    pinecone_configuration = optional(object({
      connection_string      = string
      credentials_secret_arn = string
      namespace              = optional(string)
      field_mapping = object({
        metadata_field = string
        text_field     = string
      })
    }))

    # Opción 3: RDS (PostgreSQL con pgvector)
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

    # Opción 4: Redis Enterprise Cloud
    redis_enterprise_cloud_configuration = optional(object({
      endpoint               = string
      credentials_secret_arn = string
      vector_index_name      = string
      field_mapping = object({
        metadata_field = string
        text_field     = string
        vector_field   = string
      })
    }))

    # Opción 5: Amazon S3 Vectors
    s3_vectors_configuration = optional(object({
      index_arn         = optional(string)   # ARN del S3 Vectors index (exclusivo con index_name + vector_bucket_arn)
      index_name        = optional(string)   # Nombre del index (requiere vector_bucket_arn)
      vector_bucket_arn = optional(string)   # ARN del vector bucket (requiere index_name)
    }))
  }))

  data_sources = optional(map(object({...})))  # Ver sección Data Sources
}))
```

### Estructura de `data_sources`

```hcl
data_sources = map(object({
  description = string
  kms_key_arn = optional(string)    # ARN de KMS para cifrado server-side

  data_source_configuration = object({
    type = string                   # "S3", "CONFLUENCE", "SALESFORCE", "SHAREPOINT", "WEB"

    s3_configuration = optional(object({
      bucket_arn              = string
      bucket_owner_account_id = optional(string)
      inclusion_prefixes      = optional(list(string))
    }))

    confluence_configuration = optional(object({
      auth_type              = string    # "BASIC", "OAUTH2_CLIENT_CREDENTIALS"
      credentials_secret_arn = string
      host_type              = string    # "SAAS"
      host_url               = string
    }))

    salesforce_configuration = optional(object({
      auth_type              = string    # "OAUTH2_CLIENT_CREDENTIALS"
      credentials_secret_arn = string
      host_url               = string
    }))

    share_point_configuration = optional(object({
      auth_type              = string
      credentials_secret_arn = string
      domain                 = string
      host_type              = string    # "ONLINE"
      site_urls              = list(string)
      tenant_id              = string
    }))

    web_configuration = optional(object({
      seed_urls = optional(list(object({ url = string })))
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

  vector_ingestion_configuration = optional(object({
    chunking_configuration = object({
      chunking_strategy = string    # "FIXED_SIZE", "HIERARCHICAL", "SEMANTIC", "NONE"
      fixed_size_chunking_configuration = optional(object({
        max_tokens         = number
        overlap_percentage = number
      }))
      hierarchical_chunking_configuration = optional(object({
        level_configurations = list(object({ max_tokens = number }))  # Requiere exactamente 2 niveles (parent + child)
        overlap_tokens       = number
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
      parsing_strategy = string    # "BEDROCK_FOUNDATION_MODEL", "BEDROCK_DATA_AUTOMATION"
      bedrock_foundation_model_configuration = optional(object({
        model_arn             = string
        parsing_modality      = optional(string)    # "MULTIMODAL"
        parsing_prompt_string = optional(string)
      }))
      bedrock_data_automation_configuration = optional(object({
        parsing_modality = optional(string)          # "MULTIMODAL"
      }))
    }))
  }))
}))
```

## Valores de Salida

| Name | Description |
|------|-------------|
| knowledge_base_arns | Map de knowledge base keys a sus ARNs |
| knowledge_base_ids | Map de knowledge base keys a sus IDs |
| data_source_ids | Map de data source keys a sus data source IDs |

## Backends de Almacenamiento Soportados

| Backend | `storage_configuration_type` | Descripción |
|---------|------------------------------|-------------|
| OpenSearch Serverless | `OPENSEARCH_SERVERLESS` | Colección serverless de Amazon OpenSearch |
| Pinecone | `PINECONE` | Base de datos vectorial Pinecone |
| RDS | `RDS` | PostgreSQL con extensión pgvector |
| Redis Enterprise Cloud | `REDIS_ENTERPRISE_CLOUD` | Redis Enterprise Cloud con búsqueda vectorial |
| S3 Vectors | `S3_VECTORS` | Amazon S3 Vectors para almacenamiento vectorial nativo |

## Ejemplos de Uso

### Knowledge Base con OpenSearch Serverless

```hcl
module "knowledge_base" {
  source = "git::https://repo/bedrock-knowledge-base.git?ref=v1.0.0"

  providers = {
    aws.project = aws.principal
  }

  client      = var.client
  project     = var.project
  environment = var.environment
  common_tags = var.common_tags

  knowledgebases = local.knowledgebases_transformed
}
```

```hcl
# En locals.tf del Root
locals {
  knowledgebases_transformed = {
    "documentation" = {
      type                       = "VECTOR"
      storage_configuration_type = "OPENSEARCH_SERVERLESS"
      role_arn                   = data.aws_iam_role.kb_role.arn

      vector_knowledge_base_configuration = {
        embedding_model_arn = "arn:aws:bedrock:us-east-1::foundation-model/amazon.titan-embed-text-v2:0"
        dimensions          = 1024
      }

      storage_configuration = {
        type = "OPENSEARCH_SERVERLESS"
        opensearch_serverless_configuration = {
          collection_arn    = data.aws_opensearchserverless_collection.kb.arn
          vector_index_name = "bedrock-knowledge-base-default-index"
          field_mapping = {
            metadata_field = "AMAZON_BEDROCK_METADATA"
            text_field     = "AMAZON_BEDROCK_TEXT_CHUNK"
            vector_field   = "bedrock-knowledge-base-default-vector"
          }
        }
      }

      data_sources = {
        "technical-docs" = {
          description = "Technical documentation from S3"
          data_source_configuration = {
            type = "S3"
            s3_configuration = {
              bucket_arn         = data.aws_s3_bucket.docs.arn
              inclusion_prefixes = ["docs/"]
            }
          }
          vector_ingestion_configuration = {
            chunking_configuration = {
              chunking_strategy = "FIXED_SIZE"
              fixed_size_chunking_configuration = {
                max_tokens         = 1000
                overlap_percentage = 20
              }
            }
          }
        }
      }
    }
  }
}
```

### Knowledge Base con Amazon S3 Vectors

```hcl
# En locals.tf del Root
locals {
  knowledgebases_transformed = {
    "s3vectors-kb" = {
      type                       = "VECTOR"
      storage_configuration_type = "S3_VECTORS"
      role_arn                   = data.aws_iam_role.kb_role.arn

      vector_knowledge_base_configuration = {
        embedding_model_arn = "arn:aws:bedrock:us-east-1::foundation-model/amazon.titan-embed-text-v2:0"
        dimensions          = 256
        embedding_data_type = "FLOAT32"
      }

      storage_configuration = {
        type = "S3_VECTORS"
        s3_vectors_configuration = {
          # Opción A: Usar index_arn directamente
          index_arn = data.aws_s3vectors_index.kb.index_arn

          # Opción B: Usar index_name + vector_bucket_arn
          # index_name        = "my-index"
          # vector_bucket_arn = data.aws_s3vectors_vector_bucket.kb.arn
        }
      }

      data_sources = {
        "product-catalog" = {
          description = "Product catalog from S3"
          data_source_configuration = {
            type = "S3"
            s3_configuration = {
              bucket_arn = data.aws_s3_bucket.catalog.arn
            }
          }
          vector_ingestion_configuration = {
            chunking_configuration = {
              chunking_strategy = "SEMANTIC"
              semantic_chunking_configuration = {
                breakpoint_percentile_threshold = 95
                buffer_size                     = 0
                max_token                       = 300
              }
            }
          }
        }
      }
    }
  }
}
```

### Data Source con Semantic Chunking

```hcl
# En locals.tf del Root
locals {
  knowledgebases_transformed = {
    "faq-kb" = {
      type                       = "VECTOR"
      storage_configuration_type = "OPENSEARCH_SERVERLESS"
      role_arn                   = data.aws_iam_role.kb_role.arn

      vector_knowledge_base_configuration = {
        embedding_model_arn = "arn:aws:bedrock:us-east-1::foundation-model/amazon.titan-embed-text-v2:0"
        dimensions          = 1024
      }

      storage_configuration = {
        type = "OPENSEARCH_SERVERLESS"
        opensearch_serverless_configuration = {
          collection_arn    = data.aws_opensearchserverless_collection.kb.arn
          vector_index_name = "bedrock-knowledge-base-default-index"
          field_mapping = {
            metadata_field = "AMAZON_BEDROCK_METADATA"
            text_field     = "AMAZON_BEDROCK_TEXT_CHUNK"
            vector_field   = "bedrock-knowledge-base-default-vector"
          }
        }
      }

      data_sources = {
        "faq-docs" = {
          description = "FAQ documents with semantic chunking"
          kms_key_arn = data.aws_kms_key.bedrock.arn

          data_source_configuration = {
            type = "S3"
            s3_configuration = {
              bucket_arn         = data.aws_s3_bucket.faq.arn
              inclusion_prefixes = ["faq/"]
            }
          }

          # Semantic chunking divide el contenido priorizando significado semántico
          # sobre estructura sintáctica. Ideal para documentos con secciones de
          # longitud variable como FAQs, artículos y documentación narrativa.
          vector_ingestion_configuration = {
            chunking_configuration = {
              chunking_strategy = "SEMANTIC"
              semantic_chunking_configuration = {
                # Umbral de disimilitud (1-99). Valores más altos = chunks más grandes.
                # 95 es un buen punto de partida para documentación técnica.
                breakpoint_percentile_threshold = 95
                # Número de oraciones adyacentes a considerar para el cálculo de similitud.
                # 0 = solo la oración actual, 1 = una oración antes y después.
                buffer_size = 1
                # Máximo de tokens por chunk. Limita el tamaño incluso si el contenido
                # es semánticamente coherente.
                max_token = 300
              }
            }
          }
        }
      }
    }
  }
}
```

### Data Source con Lambda de Transformación Personalizada

```hcl
# En locals.tf del Root
locals {
  knowledgebases_transformed = {
    "contracts-kb" = {
      type                       = "VECTOR"
      storage_configuration_type = "OPENSEARCH_SERVERLESS"
      role_arn                   = data.aws_iam_role.kb_role.arn

      vector_knowledge_base_configuration = {
        embedding_model_arn = "arn:aws:bedrock:us-east-1::foundation-model/amazon.titan-embed-text-v2:0"
        dimensions          = 1024
      }

      storage_configuration = {
        type = "OPENSEARCH_SERVERLESS"
        opensearch_serverless_configuration = {
          collection_arn    = data.aws_opensearchserverless_collection.kb.arn
          vector_index_name = "bedrock-knowledge-base-default-index"
          field_mapping = {
            metadata_field = "AMAZON_BEDROCK_METADATA"
            text_field     = "AMAZON_BEDROCK_TEXT_CHUNK"
            vector_field   = "bedrock-knowledge-base-default-vector"
          }
        }
      }

      data_sources = {
        "contracts" = {
          description = "Contract documents with custom Lambda transformation"
          kms_key_arn = data.aws_kms_key.bedrock.arn

          data_source_configuration = {
            type = "S3"
            s3_configuration = {
              bucket_arn         = data.aws_s3_bucket.contracts.arn
              inclusion_prefixes = ["contracts/"]
            }
          }

          vector_ingestion_configuration = {
            # Primero se aplica el chunking estándar, luego la Lambda post-procesa
            # los chunks resultantes. Útil para enriquecer metadata, filtrar contenido
            # sensible, o aplicar lógica de chunking personalizada.
            chunking_configuration = {
              chunking_strategy = "FIXED_SIZE"
              fixed_size_chunking_configuration = {
                max_tokens         = 500
                overlap_percentage = 15
              }
            }

            # La Lambda recibe los chunks desde S3 (intermediate_storage),
            # los transforma, y escribe el resultado de vuelta en S3.
            # step_to_apply solo soporta "POST_CHUNKING" actualmente.
            custom_transformation_configuration = {
              s3_uri        = "s3://${data.aws_s3_bucket.intermediate.id}/bedrock/transformations/"
              step_to_apply = "POST_CHUNKING"
              lambda_arn    = data.aws_lambda_function.chunk_transformer.arn
            }
          }
        }
      }
    }
  }
}
```

> **Nota sobre la Lambda de transformación:** La función Lambda recibe un evento con la ubicación S3 de los chunks generados por la estrategia de chunking. Debe leer los chunks, aplicar las transformaciones necesarias (enriquecer metadata, filtrar contenido, re-chunking personalizado), y escribir el resultado en la misma ubicación S3 intermedia. El rol de ejecución de la Lambda necesita permisos de lectura/escritura sobre el bucket intermedio.

Consulte el directorio `sample/` para un ejemplo funcional completo con inyección dinámica de IDs.

## Decisiones de Diseño

- **Responsabilidad Única (PC-IAC-023):** El módulo solo crea recursos intrínsecos a Bedrock Knowledge Base (`aws_bedrockagent_knowledge_base` y `aws_bedrockagent_data_source`). Los roles IAM, VPCs y Security Groups se reciben como variables de entrada.
- **Nomenclatura Centralizada (PC-IAC-003):** Los nombres se construyen en `locals.tf` usando el patrón `{client}-{project}-{environment}-kb-{key}`.
- **Cifrado (PC-IAC-020):** Se soporta cifrado KMS para data sources mediante `kms_key_arn` en `server_side_encryption_configuration`.
- **Estabilidad (PC-IAC-010):** Se usa `for_each` con `map(object)` para evitar destrucción accidental de recursos al reordenar elementos.
- **Provider Alias (PC-IAC-005):** El módulo consume el provider mediante `aws.project`, inyectado desde el Root con `configuration_aliases`.
- **Múltiples Backends (PC-IAC-014):** Se usan bloques `dynamic` para soportar los 5 backends de almacenamiento vectorial de forma condicional sin duplicar código.

## Cumplimiento PC-IAC

| Regla | Descripción | Implementación |
|-------|-------------|----------------|
| PC-IAC-001 | Estructura de Módulo | 10 archivos raíz + 8 archivos en sample/ |
| PC-IAC-002 | Variables | Validaciones en client, project, environment, common_tags, knowledgebases |
| PC-IAC-003 | Nomenclatura | Centralizada en locals.tf con governance_prefix y kb_names |
| PC-IAC-005 | Providers | Alias aws.project con configuration_aliases en versions.tf |
| PC-IAC-006 | Versiones | versions.tf con required_version >= 1.0.0 y AWS provider >= 5.0.0 |
| PC-IAC-007 | Outputs | ARNs e IDs granulares para knowledge bases y data sources |
| PC-IAC-010 | For_Each | map(object) con for_each en todos los recursos |
| PC-IAC-012 | Locals | governance_prefix, kb_names y flatten de data_sources en locals.tf |
| PC-IAC-014 | Bloques Dinámicos | dynamic blocks para 5 backends de storage y configuraciones opcionales |
| PC-IAC-020 | Seguridad | Cifrado KMS para data sources, roles IAM como input |
| PC-IAC-023 | Responsabilidad Única | Solo recursos de Bedrock KB y data sources |
| PC-IAC-026 | Patrón sample/ | Flujo tfvars → variables → data → locals → main en sample/ |

---

**Última actualización:** 17-03-2026

**Versión del documento:** 1.0.0

**Mantenido por:** Pragma - CloudOps Team

---

> Este módulo ha sido desarrollado siguiendo los estándares de Pragma CloudOps, garantizando una implementación segura, escalable y optimizada que cumple con todas las políticas de la organización. Pragma CloudOps recomienda revisar este código con su equipo de infraestructura antes de implementarlo en producción.