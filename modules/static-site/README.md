# Módulo: static-site 

  

Crea un bucket S3 configurado como sitio web estático público. 

  

## Uso 

  

```hcl 

module "site" { 

  source          = "../../modules/static-site" 

  bucket_name     = "mi-bucket-unico" 

  index_file_path = "./website/index.html" 

  environment     = "dev" 

} 

``` 

  

## Variables de entrada 

  

| Nombre | Tipo | Requerida | Descripción | 
|---|---|---|---| 
| bucket_name | string | sí | Nombre único global del bucket | 
| index_file_path | string | sí | Ruta local al archivo index.html | 
| environment | string | no (default: dev) | Nombre del ambiente | 
| tags | map(string) | no | Etiquetas adicionales | 

  

## Salidas 

  

| Nombre | Descripción | 
|---|---| 
| website_url | URL pública del sitio desplegado | 
| bucket_arn | ARN del bucket creado | 
