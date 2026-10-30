terraform {
  required_version = ">= 1.4"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

locals {
  erp_seed_version = "1"

  raw_files = setunion(
    fileset(path.module, "datos_csv/*.csv"),
    fileset(path.module, "datos_xls/*.xlsx"),
  )

  erp_sql_scripts = [
    "01_crear_esquema.sql",
    "02_catalogos.sql",
    "03_datos_2024.sql",
    "04_datos_2025.sql",
  ]
}

resource "azurerm_resource_group" "rg" {
  name     = "gr-ucb-transporte"
  location = var.location
}

resource "azurerm_storage_account" "storage" {
  name                     = "saucbtransporte${var.sufijo}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  is_hns_enabled           = true
}

resource "azurerm_storage_container" "raw" {
  name                  = "raw"
  storage_account_name  = azurerm_storage_account.storage.name
  container_access_type = "private"
}

resource "azurerm_storage_blob" "raw_files" {
  for_each               = local.raw_files
  name                   = each.value
  storage_account_name   = azurerm_storage_account.storage.name
  storage_container_name = azurerm_storage_container.raw.name
  type                   = "Block"
  source                 = "${path.module}/${each.value}"
}

resource "azurerm_mssql_server" "sql_server" {
  name                         = "sql-ucb-server-transporte-${var.sufijo}"
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = azurerm_resource_group.rg.location
  version                      = "12.0"
  administrator_login          = var.sql_admin_login
  administrator_login_password = var.sql_admin_password
}

resource "azurerm_mssql_firewall_rule" "allow_azure_services" {
  name             = "AllowAzureServices"
  server_id        = azurerm_mssql_server.sql_server.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

resource "azurerm_mssql_firewall_rule" "allow_client" {
  name             = "AllowClientIP"
  server_id        = azurerm_mssql_server.sql_server.id
  start_ip_address = var.client_ip_start
  end_ip_address   = var.client_ip_end
}

resource "azurerm_mssql_database" "db" {
  for_each = toset(["erp_transporte_db", "dw_transporte"])

  name                        = each.value
  server_id                   = azurerm_mssql_server.sql_server.id
  collation                   = "SQL_Latin1_General_CP1_CI_AS"
  sku_name                    = "GP_S_Gen5_1"
  max_size_gb                 = 32
  min_capacity                = 0.5
  auto_pause_delay_in_minutes = 60
}

resource "terraform_data" "erp_schema" {
  triggers_replace = [local.erp_seed_version]

  provisioner "local-exec" {
    interpreter = ["PowerShell", "-Command"]
    environment = {
      SQLCMDPASSWORD = var.sql_admin_password
    }
    command = <<-POWERSHELL
      $ErrorActionPreference = 'Stop'
      $server  = '${azurerm_mssql_server.sql_server.fully_qualified_domain_name}'
      $scripts = @(${join(",", [for s in local.erp_sql_scripts : "'${s}'"])})
      foreach ($scriptName in $scripts) {
        Write-Host "Ejecutando $scriptName ..."
        sqlcmd -S $server -d erp_transporte_db -U '${var.sql_admin_login}' -b -i "${path.module}/sql/$scriptName"
        if ($LASTEXITCODE -ne 0) {
          throw "Fallo $scriptName (codigo $LASTEXITCODE)."
        }
      }
    POWERSHELL
  }

  depends_on = [
    azurerm_mssql_database.db,
    azurerm_mssql_firewall_rule.allow_azure_services,
    azurerm_mssql_firewall_rule.allow_client,
  ]
}

resource "azurerm_data_factory" "adf" {
  name                = "adf-ucb-transporte-us-${var.sufijo}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.adf_location
}
