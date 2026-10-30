output "resource_group" {
  value = azurerm_resource_group.rg.name
}

output "storage_account" {
  value = azurerm_storage_account.storage.name
}

output "sql_server_fqdn" {
  value = azurerm_mssql_server.sql_server.fully_qualified_domain_name
}

output "databases" {
  value = keys(azurerm_mssql_database.db)
}

output "data_factory" {
  value = azurerm_data_factory.adf.name
}
