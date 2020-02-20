variable release_name {
  type = string
}

# variable src_repo {
#     type = string
# }

variable chart_name {
  type = string
}

variable "chart_url" {
  type    = string
  default = "https://kubernetes-charts.storage.googleapis.com"
}


# variable version {
#     type = string
#     default = ""
# }

variable namespace {
  type    = string
  default = "default"
}

variable set_values {
  type    = list
  default = []
}

variable "local_chart" {
  type    = bool
  default = false
}

variable base_domain {
  type    = string
  default = ""
}

variable subdomain {
  type    = string
  default = ""
}
