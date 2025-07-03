# Lambda Layers Module - Sample

## Descripción

Este directorio contiene un ejemplo completo de cómo usar el módulo `lambda-layers` para crear y gestionar AWS Lambda Layers.

## Estructura de archivos

```
sample/
├── README.md                        # Este archivo
├── data.tf                         # Fuentes de datos
├── main.tf                         # Configuración principal del ejemplo
├── outputs.tf                      # Outputs del ejemplo
├── providers.tf                    # Configuración de proveedores
├── terraform.auto.tfvars.sample    # Valores de ejemplo
└── variables.tf                    # Variables del ejemplo
```

## Requisitos previos

- Terraform >= 1.0
- AWS CLI configurado
- Acceso a AWS con permisos de Lambda y CloudWatch

## Cómo usar este ejemplo

1. **Copiar archivos de ejemplo**:
   ```bash
   cp terraform.auto.tfvars.sample terraform.auto.tfvars
   ```

2. **Modificar valores**:
   Editar `terraform.auto.tfvars` con tus valores específicos

3. **Ejecutar Terraform**:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Escenarios incluidos

- **Layer compilado**: Ejemplo con script de compilación automática
- **Layer desde archivo**: Ejemplo usando ZIP preexistente
- **Layer desde S3**: Ejemplo para pipelines CI/CD

## Flujos de trabajo recomendados

### Desarrollo Local
1. Usar tipo `compile` para desarrollo iterativo
2. Scripts automatizan la instalación de dependencias
3. Testing local antes de despliegue

### Pipeline CI/CD
1. Usar tipo `s3` para artefactos pre-compilados
2. Gestión de versiones con source_code_hash
3. Despliegue automatizado

## Integración con otros servicios AWS

- **Lambda Functions**: Los layers creados pueden ser referenciados por ARN
- **CloudWatch**: Logs automáticos de compilación
- **S3**: Almacenamiento de artefactos para pipelines

## Solución de problemas comunes

### Error: "Archive would be empty"
- Verificar que los scripts de compilación creen contenido
- Revisar permisos de ejecución en scripts
- Validar rutas de directorios

### Error: "Layer name already exists"
- Verificar nombres únicos por región
- Considerar usar prefijos por ambiente
- Revisar tags para identificación

## Limpieza

```bash
terraform destroy
```

**Nota**: Los layers no se eliminan automáticamente si están en uso por funciones Lambda.