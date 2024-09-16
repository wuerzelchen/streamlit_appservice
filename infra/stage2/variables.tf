variable "tags" {
  type = map(string)
  default = {
    source = "Samples/Python/AADStreamlit/Stage2"
  }
}

variable "resource_group_name" {
  type = string
}

variable "container_registry_name" {
  type = string
}
