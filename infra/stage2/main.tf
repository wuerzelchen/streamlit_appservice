#resource group
data "http" "myip" {
  #url = "https://ipv4.icanhazip.com"
  url = "https://api.ipify.org?format=raw"
}
