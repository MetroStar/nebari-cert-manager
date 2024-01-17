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

variable "chart_namespace" {
  description = "Namespace of Helm Release"
  type = string
}

variable "namespace" {
  description = "Namespace of Secret, Issuers, and Certificates"
  type = string
}

variable "certificates" {
  type = list(object({
    issuer = string
  }))
}

variable "issuers" {
  type = list(object({
    name = string
    type = string
    keyId = string
    existingSecret = string
  }))
}

variable "overrides" {
  type    = map(any)
  default = {}
}
