# Bedrock Knowledge Base Module - Ejemplo de Uso

## Descripción

Este directorio contiene un ejemplo completo de cómo usar el módulo `bedrock-knowledge-base` para crear y gestionar Knowledge Bases en AWS Bedrock con OpenSearch Serverless como backend de almacenamiento vectorial.

El módulo también soporta Pinecone, RDS (pgvector), Redis Enterprise Cloud y Amazon S3 Vectors como backends alternativos.

## Estructura de archivos

```
sample/
├── README.md           # Este archivo
├── data.tf             # Data sources para obtener IDs dinámicos
├── locals.tf           # Transformaciones e inyección de IDs dinámicos
├── main.tf             # Invocación del módulo padre
├── outputs.tf          # Outputs del ejemplo
├── providers.tf        # Configuración de providers
├── terraform.tfvars    # Valores de ejemplo
└── variables.tf        # Variables del ejemplo
```

## Requisitos previos

- Terraform >= 1.0
- AWS CLI configurado con perfil válido
- Acceso a AWS con permisos de Bedrock, OpenSearch Serverless y S3
- Recursos existentes:
  - Colección OpenSearch Serverless (o el backend vectorial elegido)
  - Rol IAM con permisos para Bedrock Knowledge Base
  - Bucket S3 con los documentos fuente
  - KMS Key para cifrado (opcional)

## Cómo usar este ejemplo

1. Copiar y ajustar los valores en `terraform.tfvars` con los datos de su ambiente
2. Verificar que los recursos referenciados en `data.tf` existan (rol IAM, colección AOSS, bucket S3, KMS key)
3. Ejecutar Terraform:

   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Flujo de datos (PC-IAC-026)

```
terraform.tfvars → variables.tf → data.tf → locals.tf → main.tf → ../
     (config)        (tipos)     (consulta)  (transform)  (invoca módulo padre)
```

Los campos vacíos (`""`) en `terraform.tfvars` se llenan automáticamente en `locals.tf` con los valores obtenidos de los data sources en `data.tf`.

## Backends de almacenamiento

El ejemplo usa OpenSearch Serverless por defecto. Para usar otro backend, modifique `storage_configuration_type` y el bloque `storage_configuration` correspondiente en `terraform.tfvars`:

- `OPENSEARCH_SERVERLESS` → `opensearch_serverless_configuration`
- `PINECONE` → `pinecone_configuration`
- `RDS` → `rds_configuration`
- `REDIS_ENTERPRISE_CLOUD` → `redis_enterprise_cloud_configuration`
- `S3_VECTORS` → `s3_vectors_configuration`

## Limpieza

```bash
terraform destroy
```
