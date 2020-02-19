# NAMESPACE: metrics
resource "kubernetes_namespace" "metrics" {
  metadata {
    name = "metrics"
  }
}

# NAMESPACE: metrics
resource "kubernetes_namespace" "nginx_ingress" {
  metadata {
    name = "nginx-ingress"
  }
}

resource "kubernetes_namespace" "kiam" {
  metadata {
    name = "kiam"
  }
}

resource "kubernetes_namespace" "cert_manager" {
  metadata {
    name = "cert-manager"
    annotations = {
      "iam.amazonaws.com/permitted" = "EKSDemo/kiam/EKSKiamCertManger"
    }
  }
}

resource "kubernetes_namespace" "apps" {
  metadata {
    name = "apps"
  }
}

resource "kubernetes_namespace" "external_dns" {
  metadata {
    name = "external-dns"
    annotations = {
      "iam.amazonaws.com/permitted" = "EKSDemo/kiam/EKSKiamExternalDNS"
    }
  }
}