output update_kubeconfig_cmd {
  value = "aws eks --region ${var.region} update-kubeconfig --name ${var.cluster_name}"
}

output switch_cluster_context {
  value = "kubectl config use-context ${aws_eks_cluster.demo.arn}"
}