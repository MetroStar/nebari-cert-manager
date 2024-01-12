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

variable "overrides" {
  type    = map(any)
  default = {}
}

variable "solver_type" {
  type = string
}
