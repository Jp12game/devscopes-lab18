terraform { 

  required_version = ">= 1.5.0" 

  required_providers { 

    aws = { 

      source  = "hashicorp/aws" 

      version = "~> 5.0" 

    } 

  } 

  backend "s3" {
    bucket         = "devsecops-lab-polanco-dev-tfstate-2026"
    key            = "static-site/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
} 

  

provider "aws" { 

  region = "us-east-1" 

} 

locals {
  # Traduce el nombre real del workspace a un "alias" para nombrar recursos.
  # El workspace "default" (el que ya tiene el bucket de dev del Lab 5)
  # se sigue llamando "dev" a efectos de nomenclatura.
  workspace_aliases = {
    default = "dev"
  }
  environment_name = lookup(local.workspace_aliases, terraform.workspace, terraform.workspace)
 
  environment_settings = {
    dev     = { tags = { Criticidad = "baja" } }
    staging = { tags = { Criticidad = "media" } }
    prod    = { tags = { Criticidad = "alta" } }
  }
}
  

module "site" {
  source          = "../../modules/static-site"
  bucket_name     = "devsecops-lab-polanco-${local.environment_name}-2026"
  index_file_path = "${path.module}/../../website/index.html"
  environment     = local.environment_name
  tags            = local.environment_settings[local.environment_name].tags
}
