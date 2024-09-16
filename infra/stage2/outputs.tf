# database endpoint output
output "database_endpoint" {
  value = azurerm_postgresql_flexible_server.pg.fqdn
}
