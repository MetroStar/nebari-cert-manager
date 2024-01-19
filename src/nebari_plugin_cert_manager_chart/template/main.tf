locals {
  name                = var.name
  domain              = var.domain
  zone                = var.zone
  create_namespace = var.create_namespace
  namespace        = var.namespace
  solver = var.solver
  certificates = var.certificates
  apikey = var.apikey
  issuers = var.issuers
  overrides        = var.overrides

  chart_namespace = local.create_namespace ? kubernetes_namespace.this[0].metadata[0].name : local.namespace
}

resource "kubernetes_namespace" "this" {
  count = local.create_namespace ? 1 : 0

  metadata {
    name = local.issuers[0].namespace
  }
}

resource "kubernetes_secret" "cloudflare-apikey" {
  count = local.solver == "cloudflare" ? 1 : 0

  metadata {
    name      = "cloudflare-apikey"
    namespace = local.namespace
  }

  data = {
    key     = local.apikey
  }
}

resource "helm_release" "this" {
  name      = local.name
  chart     = "./chart"
  namespace = local.chart_namespace

  dependency_update = true

  values = [
    yamlencode({
      certificates = [
        for certificate in local.certificates : {
          name = certificate.name
          namespace = certificate.namespace
          issuer = certificate.issuer
          dnsNames = [local.domain, "*.${local.domain}"]
        }
      ]
      issuers = [
        for issuer in local.issuers : {
          name = issuer.name
          namespace = issuer.namespace
          type = issuer.type
          email = local.email
          keyId = issuer.keyId
          existingSecret = issuer.existingSecret
          solver = {
            type = local.solver
            existingSecret = local.solver == "cloudflare" ? kubernetes_secret.cloudflare-apikey.metadata[0].name : ""
          }
        }
      ]
      cloudflare = {
        zone = local.zone
        email = local.email
      }
    }),
    yamlencode(local.overrides),
  ]
}
