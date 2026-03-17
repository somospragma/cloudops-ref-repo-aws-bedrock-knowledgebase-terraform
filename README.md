# Módulo Terraform: bedrock-knowledge-base

## Descripción

Este módulo gestiona la creación y configuración de Knowledge Bases en AWS Bedrock con soporte para múltiples tipos de fuentes de datos. Proporciona una interfaz unificada para desplegar bases de conocimiento con diferentes configuraciones de almacenamiento y capacidades de ingesta de datos.

Para más detalles sobre los cambios y versiones, consulte el [CHANGELOG.md](./CHANGELOG.md).

## Características

- Soporte para múltiples tipos de almacenamiento (OpenSearch Serverless, Pinecone, RDS, Redis Enterprise Cloud)
- Configuración flexible de fuentes de datos (S3, Confluence, Salesforce, SharePoint, Web)
- Configuración de ingesta vectorial con estrategias de chunking personalizables
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

- `aws_bedrockagent_knowledge_base`: Knowledge Bases en Bedrock
- `aws_bedrockagent_data_source`: Fuentes de datos para Knowledge Bases

## Parámetros de Entrada

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| knowledgebases | Mapa de configuración de Knowledge Bases | `map(object)` | n/a | yes |
| client | Nombre del cliente (max 10 chars) | `string` | n/a | yes |
| project | Nombre del proyecto (max 15 chars) | `string` | n/a | yes |
| environment | Entorno de despliegue (dev, qa, pdn) | `string` | n/a | yes |
| common_tags | Tags comunes para todos los recursos | `map(string)` | n/a | yes |

## Valores de Salida

| Name | Description |
|------|-------------|
| knowledge_base_arns | Map de knowledge base keys a sus ARNs |
| knowledge_base_ids | Map de knowledge base keys a sus IDs |
| data_source_ids | Map de data source keys a sus IDs |

## Ejemplo de Uso

```hcl
module "knowledge_base" {
  source  = "git::https://repo/bedrock-knowledge-base.git?ref=v1.0.0"

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

Consulte el directorio `sample/` para un ejemplo funcional completo.

## Decisiones de Diseño

- **Responsabilidad Única (PC-IAC-023):** El módulo solo crea recursos intrínsecos a Bedrock Knowledge Base. Los roles IAM, VPCs y Security Groups se reciben como variables de entrada.
- **Nomenclatura Centralizada (PC-IAC-003):** Los nombres se construyen en `locals.tf` usando el patrón `{client}-{project}-{environment}-kb-{key}`.
- **Cifrado (PC-IAC-020):** Se soporta cifrado KMS para data sources mediante `kms_key_arn`.
- **Estabilidad (PC-IAC-010):** Se usa `for_each` con `map(object)` para evitar destrucción accidental de recursos.
- **Provider Alias (PC-IAC-005):** El módulo consume el provider mediante `aws.project`, inyectado desde el Root.

## Cumplimiento PC-IAC

| Regla | Descripción | Implementación |
|-------|-------------|----------------|
| PC-IAC-001 | Estructura de Módulo | 10 archivos raíz + 8 archivos en sample/ |
| PC-IAC-002 | Variables | Validaciones en client, project, environment, common_tags |
| PC-IAC-003 | Nomenclatura | Centralizada en locals.tf con governance_prefix |
| PC-IAC-005 | Providers | Alias aws.project con configuration_aliases |
| PC-IAC-006 | Versiones | versions.tf con required_version y provider pinning |
| PC-IAC-007 | Outputs | ARNs e IDs granulares para KB y data sources |
| PC-IAC-010 | For_Each | map(object) con for_each en todos los recursos |
| PC-IAC-014 | Bloques Dinámicos | dynamic blocks para configuraciones opcionales |
| PC-IAC-020 | Seguridad | Cifrado KMS, roles como input |
| PC-IAC-023 | Responsabilidad Única | Solo recursos de Bedrock KB y data sources |