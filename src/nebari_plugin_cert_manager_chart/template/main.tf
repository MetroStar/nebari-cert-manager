locals {
  name                = var.name
  domain              = var.domain
  zone                = var.zone
  create_chart_namespace = var.create_chart_namespace
  chart_namespace = var.chart_namespace
  namespace        = var.namespace
  solver_type = var.solver_type
  certificates = var.certificates
  issuers = var.issuers
  overrides        = var.overrides

  chart_namespace = local.create_chart_namespace ? kubernetes_namespace.this[0].metadata[0].name : local.namespace
}

resource "kubernetes_namespace" "this" {
  count = local.create_chart_namespace ? 1 : 0

  metadata {
    name = local.chart_namespace
  }
}

resource "kubernetes_secret" "cloudflare-apikey" {
  count = local.solver_type == "cloudflare" ? 1 : 0

  metadata {
    name      = "cloudflare-apikey"
    namespace = local.namespace
  }

  data = {
    key     = local.key
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
