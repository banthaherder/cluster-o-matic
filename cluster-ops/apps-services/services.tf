module "hello_k8s" {
  source       = "../../modules"
  release_name = "hello-k8s"
  namespace    = "apps"
  chart_name   = "hello-k8s"
  local_chart  = true
  base_domain  = "banthabot.com"
  subdomain    = "hello-k8s"
}
