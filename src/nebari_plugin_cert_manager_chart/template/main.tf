locals {
  name                = var.name
  domain              = var.domain
  zone                = var.zone
  create_namespace = var.create_namespace
  namespace        = var.namespace
  overrides        = var.overrides

  solver_type = var.solver_type

  chart_namespace = local.create_namespace ? kubernetes_namespace.this[0].metadata[0].name : local.namespace
}

resource "kubernetes_namespace" "this" {
  count = local.create_namespace ? 1 : 0

  metadata {
    name = local.namespace
  }
}

resource "helm_release" "this" {
  name      = local.name
  chart     = "./chart"
  namespace = local.chart_namespace

  dependency_update = true

  values = [
    yamlencode({
      certificates = {
        dnsNames = [local.domain, *.${local.domain}]
      }
      issuers = {
        solver = {
          type = local.solver_type
          existingSecret = local.solver_type == "cloudflare" ? kubernetes_secret.auth[0].metadata[0].name : ""
        }
      }
      cloudflare = {
        zone = local.zone
      }
    }),
    yamlencode(local.overrides),
  ]
}
