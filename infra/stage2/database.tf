#postgres flexible server
resource "azurerm_postgresql_flexible_server" "pg" {
  name                          = "pg-${local.projectname}-${random_id.suffix.hex}"
  resource_group_name           = data.azurerm_resource_group.rg.name
  location                      = data.azurerm_resource_group.rg.location
  sku_name                      = "B_Standard_B1ms"
  storage_mb                    = 32768
  version                       = "15"
  auto_grow_enabled             = false
  backup_retention_days         = 7
  geo_redundant_backup_enabled  = false
  public_network_access_enabled = true
  zone                          = 1
  authentication {
    active_directory_auth_enabled = true
    password_auth_enabled         = false
    tenant_id                     = data.azurerm_client_config.current.tenant_id
  }
  tags = var.tags
}

#postgres flexible server entra id admin
resource "azurerm_postgresql_flexible_server_active_directory_administrator" "admin" {
  server_name         = azurerm_postgresql_flexible_server.pg.name
  resource_group_name = data.azurerm_resource_group.rg.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  object_id           = data.azurerm_client_config.current.object_id
  principal_name      = "admin@MngEnvMCAP953636.onmicrosoft.com"
  principal_type      = "User"
}

#firewall rule which adds current client ip
resource "azurerm_postgresql_flexible_server_firewall_rule" "firewall" {
  server_id        = azurerm_postgresql_flexible_server.pg.id
  start_ip_address = chomp(data.http.myip.response_body)
  end_ip_address   = chomp(data.http.myip.response_body)
  name             = "AllowMyIP"
}
