data "helm_repository" "chart" {
  count = var.local_chart ? 0 : 1
  name  = var.chart_name
  url   = var.chart_url
}

resource "helm_release" "demo" {
  name      = var.release_name
  namespace = var.namespace
  chart     = var.local_chart ? dirname("${path.cwd}/charts/${var.release_name}/Chart.yaml") : data.helm_repository.chart[0].metadata[0].name
  #   version    = var.version
  #   repository = var.src_repo

  values = [
    var.base_domain != "" ? templatefile("${path.cwd}/service-values/${var.release_name}-values.yaml",
      {
        base_domain = var.base_domain,
        subdomain   = var.subdomain
      },
    ) : "${file("${path.cwd}/service-values/${var.release_name}-values.yaml")}"
  ]

  dynamic "set" {
    for_each = var.set_values

    content {
      name  = set.name
      value = set.value
    }
  }
}
