# Changelog

## [Unreleased]

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
