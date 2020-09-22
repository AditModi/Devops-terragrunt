# Configuration for Storage Account Static Website module

# Loads configuration from parent folders of common variables like Location and Environment
locals {
  location_vars = read_terragrunt_config(find_in_parent_folders("location.hcl"))
  env_vars      = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  global_vars   = read_terragrunt_config(find_in_parent_folders("global.hcl"))

  location = local.location_vars.locals.location
  env      = local.env_vars.locals.env
  suffix   = local.env_vars.locals.suffix
  project  = local.global_vars.locals.project

  storage_account_name = "st${local.project}${local.env}${local.suffix}"
}

# Specify the path to the source of the module
terraform {
  source = "../../../../modules//azurerm_storage_account_static_website"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

# define dependency on modules and their outputs
dependency "resource_group" {
  config_path = "../resource_group"
  mock_outputs = {
    resource_name = "mockOutput"
  }
}

# Set inputs to pass as variables to the module
inputs = {
  name                = local.storage_account_name
  location            = local.location
  resource_group_name = dependency.resource_group.outputs.resource_name

  account_tier             = "Standard"
  account_replication_type = "RAGRS"
  access_tier              = "Hot"

  environment = local.env

  index_document     = "index.html"
  error_404_document = "index.html"
}
