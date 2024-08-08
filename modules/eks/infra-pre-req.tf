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
    null_resource.kube-config
  ]

  name       = "prom-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = "kube-system"
}

resource "kubernetes_manifest" "grafana-ingress" {
  depends_on = [
    null_resource.kube-config,
    helm_release.prometheus-stack
  ]
  manifest = {
    "apiVersion" = "networking.k8s.io/v1"
    "kind"       = "Ingress"
    "metadata" = {
      "name"      = "grafana"
      "namespace" = "kube-system"
    }
    "spec" = {
      "ingressClassName": "nginx"
      "rules" : [
        {
          "host" : "grafana-${var.name}-${var.env}.rdevopsb72.online"
          "http" : {
            "paths" : [
              {
                "pathType" : "Prefix"
                "path" : "/"
                "backend" : {
                  "service" : {
                    "name": "ingress-nginx-controller"
                    "port" : {
                      number: 80
                    }
                  }
                }
              }
            ]
          }
        }
      ]
    }
  }
}

