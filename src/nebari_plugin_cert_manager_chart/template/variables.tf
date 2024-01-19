variable "name" {
  description = "Chart name"
  type        = string
}

variable "domain" {
  description = "Domain"
  type        = string
}

variable "zone" {
  description = "Zone"
  type        = string
}

variable "create_namespace" {
  type = bool
}

variable "namespace" {
  type = string
}

variable "solver" {
  description = "Solver Type for ACME Challenge"
  type = string
}

variable "certificates" {
  type = list(object({
    name = string
    namespace = string
    issuer = string
  }))
}

variable "apikey" {
  type = string
}

variable "issuers" {
  type = list(object({
    name = string
    namespace = string
    type = string
    keyId = string
    existingSecret = string
  }))
}

variable "overrides" {
  type    = map(any)
  default = {}
}
