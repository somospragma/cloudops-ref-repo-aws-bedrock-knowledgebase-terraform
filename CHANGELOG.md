# Changelog

## [Unreleased]

## [1.1.0] - 2025-03-17

### Added

- Soporte para vector store de tipo Amazon S3 Vectors (`s3_vectors_configuration`) con opciones `index_arn` o `index_name` + `vector_bucket_arn`.
- Documentación completa de la estructura de la variable `knowledgebases` y `data_sources` en README.md.
- Tabla de backends de almacenamiento soportados en README.md.
- Ejemplos de uso con OpenSearch Serverless y S3 Vectors en README.md.

### Changed

- Actualizado `sample/README.md` con información de todos los backends soportados.

## [1.0.0] - 2025-03-17

### Added

- Recurso `aws_bedrockagent_knowledge_base` con soporte para múltiples backends de almacenamiento (OpenSearch Serverless, Pinecone, RDS, Redis Enterprise Cloud).
- Recurso `aws_bedrockagent_data_source` con soporte para S3, Confluence, Salesforce, SharePoint y Web.
- Configuración de ingesta vectorial con estrategias de chunking (fixed size, hierarchical, semantic).
- Soporte para parsing con modelos de Bedrock Foundation.
- Soporte para transformaciones personalizadas con Lambda.
- Cifrado server-side con KMS para data sources.
- Sistema de etiquetado con `common_tags` y `additional_tags`.
- Directorio `sample/` con ejemplo funcional de uso del módulo.
