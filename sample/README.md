# Bedrock Knowledge Base Module - Ejemplo de Uso

## Descripción

Este directorio contiene un ejemplo completo de cómo usar el módulo `bedrock-knowledge-base` para crear y gestionar Knowledge Bases en AWS Bedrock.

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
- AWS CLI configurado
- Acceso a AWS con permisos de Bedrock, OpenSearch Serverless y S3
- Colección OpenSearch Serverless existente
- Rol IAM con permisos para Bedrock Knowledge Base
- Bucket S3 con los documentos fuente

## Cómo usar este ejemplo

1. Copiar y ajustar los valores en `terraform.tfvars`
2. Ejecutar Terraform:

   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Flujo de datos (PC-IAC-026)

```
terraform.tfvars → variables.tf → data.tf → locals.tf → main.tf → ../
```

## Limpieza

```bash
terraform destroy
```
