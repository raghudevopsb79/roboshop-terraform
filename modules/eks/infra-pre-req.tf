resource "null_resource" "kube-config" {
  depends_on = [
    aws_eks_cluster.main,
    aws_eks_node_group.main
  ]
  provisioner "local-exec" {
    command =<<EOF
aws eks update-kubeconfig --name ${aws_eks_cluster.main.name}
EOF
  }
}

## Nginx Ingress
resource "helm_release" "nginx-ingress" {
  depends_on = [
    null_resource.kube-config
  ]

  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace  = "kube-system"

  values = [
    file("${path.module}/conf/nginx-ingress.yaml")
  ]
}

