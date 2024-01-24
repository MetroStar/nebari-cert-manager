locals {
  name                        = var.name
  domain                      = var.domain
  zone                        = var.zone
  create_namespace            = var.create_namespace
  namespace                   = var.namespace
  create_components_namespace = var.create_namespace
  comp_namespace              = var.comp_namespace
  email                       = var.email
  solver                      = var.solver
  staging                     = var.staging
  certificates                = var.certificates
  apikey                      = var.apikey
  issuers                     = var.issuers
  overrides                   = var.overrides

  chart_namespace      = local.create_namespace ? kubernetes_namespace.this[0].metadata[0].name : local.namespace
  components_namespace = local.create_components_namespace ? kubernetes_namespace.components[0].metadata[0].name : local.chart_namespace
}

resource "kubernetes_namespace" "this" {
  count = local.create_namespace ? 1 : 0

  metadata {
    name = local.namespace
  }
}

resource "kubernetes_namespace" "components" {
  count = local.create_components_namespace ? 1 : 0

  metadata {
    name = local.comp_namespace
  }
}

resource "kubernetes_secret" "cloudflare-apikey" {
  count = local.solver == "cloudflare" ? 1 : 0

  metadata {
    name      = "cloudflare-apikey"
    namespace = local.components_namespace
  }

  data = {
    key = local.apikey
  }
}

resource "helm_release" "this" {
  name      = local.chart_namespace
  chart     = "./chart"
  namespace = local.chart_namespace

  dependency_update = true

  values = [
    yamlencode({
      certificates = [
        for certificate in local.certificates : {
          name      = certificate.name
          namespace = local.components_namespace
          issuer    = certificate.issuer
          dnsNames  = [local.domain, "*.${local.domain}"]
        }
      ]
      issuers = [
        for issuer in local.issuers : {
          name           = issuer.name
          namespace      = local.components_namespace
          type           = issuer.type
          server         = local.staging && issuer.type == "letsencrypt" ? "https://acme-staging-v02.api.letsencrypt.org/directory" : "https://acme-v02.api.letsencrypt.org/directory"
          email          = local.email
          keyId          = issuer.keyId
          existingSecret = issuer.existingSecret
          solver = {
            type           = local.solver
            existingSecret = local.solver == "cloudflare" ? kubernetes_secret.cloudflare-apikey[0].metadata[0].name : ""
          }
        }
      ]
      cloudflare = {
        zone  = local.zone
        email = local.email
      }
    }),
    yamlencode(local.overrides),
  ]
}
