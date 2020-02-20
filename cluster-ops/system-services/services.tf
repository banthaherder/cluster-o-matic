module "metrics_server" {
  source       = "../../modules"
  release_name = "metrics-server"
  namespace    = "metrics"
  chart_name   = "stable/metrics-server"
}

module "ngnix_ingress" {
  source       = "../../modules"
  release_name = "nginx-ingress"
  namespace    = "nginx-ingress"
  chart_name   = "stable/nginx-ingress"
}

module "kiam" {
  source       = "../../modules"
  release_name = "kiam"
  namespace    = "kiam"
  chart_name   = "uswitch/kiam"
  chart_url    = "https://uswitch.github.io/kiam-helm-charts/charts"
}

module "cert_manager" {
  source       = "../../modules"
  release_name = "cert-manager"
  namespace    = "cert-manager"
  chart_name   = "jetstack/cert-manager"
  chart_url    = "https://charts.jetstack.io"
}

module "external_dns" {
  source       = "../../modules"
  release_name = "external-dns"
  namespace    = "external-dns"
  chart_name   = "stable/external-dns"
}
