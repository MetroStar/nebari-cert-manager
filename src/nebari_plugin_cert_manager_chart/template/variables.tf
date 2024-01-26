variable "domain" {
  type = string
}

variable "zone" {
  type = string
}

variable "create_namespace" {
  type = bool
}

variable "namespace" {
  type = string
}

variable "create_components_namespace" {
  type = bool
}

variable "comp_namespace" {
  type = string
}

variable "email" {
  type = string
}

variable "solver" {
  type = string
}

variable "staging" {
  type = bool
}

variable "certificates" {
  type = list(object({
    name   = string
    issuer = string
  }))
}

variable "apikey" {
  type = string
}

variable "issuers" {
  type = list(object({
    name           = string
    type           = string
    keyId          = string
    existingSecret = string
  }))
}

variable "overrides" {
  type    = any
  default = {}
}
