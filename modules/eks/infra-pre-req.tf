resource "null_resource" "kube-config" {
  depends_on = [
    aws_eks_cluster.main,
    aws_eks_node_group.main
  ]
  provisioner "local-exec" {
    command = <<EOF
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


## External DNS
resource "helm_release" "external-dns" {
  depends_on = [
    null_resource.kube-config,
    aws_eks_pod_identity_association.external-dns
  ]

  name       = "external-dns"
  repository = "https://kubernetes-sigs.github.io/external-dns"
  chart      = "external-dns"
  namespace  = "kube-system"
}

resource "aws_eks_pod_identity_association" "external-dns" {
  cluster_name    = aws_eks_cluster.main.name
  namespace       = "kube-system"
  service_account = "external-dns"
  role_arn        = aws_iam_role.external-dns-role.arn
}


# Prometheus Stack
resource "helm_release" "prometheus-stack" {
  depends_on = [
    null_resource.kube-config,
    helm_release.nginx-ingress
  ]

  name       = "prom-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = "kube-system"

  values = [
    file("${path.module}/conf/prometheus-stack.yaml")
  ]

  set_list {
    name  = "grafana.ingress.hosts"
    value = ["grafana-${var.name}-${var.env}.rdevopsb79.online"]
  }

  set_list {
    name  = "prometheus.ingress.hosts"
    value = ["prometheus-${var.name}-${var.env}.rdevopsb79.online"]
  }

}

## Horizontal Pod Auto scaler - Metric Server

resource "null_resource" "metric-server" {
  depends_on = [
    null_resource.kube-config
  ]
  provisioner "local-exec" {
    command = <<EOF
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
EOF
  }
}

# Cluster Auto scaler
resource "helm_release" "node-autoscaler" {
  depends_on = [
    null_resource.kube-config
  ]

  name       = "node-autoscaler"
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  namespace  = "kube-system"

  set {
    name  = "autoDiscovery.clusterName"
    value = aws_eks_cluster.main.name
  }

}

resource "aws_eks_pod_identity_association" "node-autoscaler" {
  cluster_name    = aws_eks_cluster.main.name
  namespace       = "kube-system"
  service_account = "node-autoscaler-aws-cluster-autoscaler"
  role_arn        = aws_iam_role.node-autoscaler-role.arn
}

# FluentD Helm Chart
resource "helm_release" "fluentd" {
  depends_on = [
    null_resource.kube-config
  ]

  name       = "fluentd"
  repository = "https://fluent.github.io/helm-charts"
  chart      = "fluentd"
  namespace  = "kube-system"

  values = [
    data.template_file.logstash-input.rendered
  ]
}


# Argocd Helm Chart
resource "helm_release" "argocd" {
  depends_on = [
    null_resource.kube-config
  ]

  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true

  set {
    name  = "global.domain"
    value = "argocd-${var.name}-${var.env}.rdevopsb79.online"
  }

  set {
    name  = "server.ingress.enabled"
    value = true
  }

  set {
    name  = "server.ingress.ingressClassName"
    value = "nginx"
  }
}
