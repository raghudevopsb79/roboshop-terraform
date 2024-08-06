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
resource "null_resource" "nginx-ingress" {
  depends_on = [
    null_resource.kube-config
  ]

  provisioner "local-exec" {
    command =<<EOF
helm upgrade --install ingress-nginx ingress-nginx --repo https://kubernetes.github.io/ingress-nginx --namespace kube-system
EOF
  }
}

