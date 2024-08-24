resource "aws_iam_role" "eks-role" {
  name = "${var.name}-${var.env}-eks-cluster-role"
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "eks-role-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks-role.name
}

resource "aws_iam_role_policy_attachment" "eks-role-AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks-role.name
}

resource "aws_iam_role" "node-role" {
  name = "${var.name}-${var.env}-eks-node-role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "node-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node-role.name
}

resource "aws_iam_role_policy_attachment" "node-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node-role.name
}

resource "aws_iam_role_policy_attachment" "node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node-role.name
}



## External DNS

resource "aws_iam_role" "external-dns-role" {
  name = "${var.name}-${var.env}-eks-external-dns-role"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "pods.eks.amazonaws.com"
        },
        "Action" : [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
      }
    ]
  })

  inline_policy {
    name = "route53-for-external-dns"

    policy = jsonencode({
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "route53:ChangeResourceRecordSets"
          ],
          "Resource" : [
            "arn:aws:route53:::hostedzone/*"
          ]
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "route53:ListHostedZones",
            "route53:ListResourceRecordSets",
            "route53:ListTagsForResource"
          ],
          "Resource" : [
            "*"
          ]
        }
      ]
    })
  }

}


## Node Autoscaler
resource "aws_iam_role" "node-autoscaler-role" {
  name = "${var.name}-${var.env}-eks-node-autoscaler-role"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "pods.eks.amazonaws.com"
        },
        "Action" : [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
      }
    ]
  })

  inline_policy {
    name = "node-auto-scaler-policy"

    policy = jsonencode({
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "autoscaling:DescribeAutoScalingGroups",
            "autoscaling:DescribeAutoScalingInstances",
            "autoscaling:DescribeLaunchConfigurations",
            "autoscaling:DescribeScalingActivities",
            "ec2:DescribeImages",
            "ec2:DescribeInstanceTypes",
            "ec2:DescribeLaunchTemplateVersions",
            "ec2:GetInstanceTypesFromInstanceRequirements",
            "eks:DescribeNodegroup"
          ],
          "Resource" : ["*"]
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "autoscaling:SetDesiredCapacity",
            "autoscaling:TerminateInstanceInAutoScalingGroup"
          ],
          "Resource" : ["*"]
        }
      ]
    })
  }

}

## EBS Storage Class
resource "aws_iam_role" "ebs-sc-role" {
  name = "${var.name}-${var.env}-ebs-sc-role"

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": "sts:AssumeRoleWithWebIdentity",
        "Principal": {
          "Federated": "arn:aws:iam::739561048503:oidc-provider/oidc.eks.us-east-1.amazonaws.com/id/AA181460F3CC5481F66827D0F24D9A40"
        },
        "Condition": {
          "StringEquals": {
            "oidc.eks.us-east-1.amazonaws.com/id/AA181460F3CC5481F66827D0F24D9A40:aud": "sts.amazonaws.com",
            "oidc.eks.us-east-1.amazonaws.com/id/AA181460F3CC5481F66827D0F24D9A40:sub": "system:serviceaccount:kube-system:ebs-csi-controller-sa"
          }
        }
      }
    ]
  })

  inline_policy {
    name = "ebs-sc-role-policy"

    policy = jsonencode({
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Action": [
            "ec2:CreateSnapshot",
            "ec2:AttachVolume",
            "ec2:DetachVolume",
            "ec2:ModifyVolume",
            "ec2:DescribeAvailabilityZones",
            "ec2:DescribeInstances",
            "ec2:DescribeSnapshots",
            "ec2:DescribeTags",
            "ec2:DescribeVolumes",
            "ec2:DescribeVolumesModifications"
          ],
          "Resource": "*"
        },
        {
          "Effect": "Allow",
          "Action": [
            "ec2:CreateTags"
          ],
          "Resource": [
            "arn:aws:ec2:*:*:volume/*",
            "arn:aws:ec2:*:*:snapshot/*"
          ]
        },
        {
          "Effect": "Allow",
          "Action": [
            "ec2:DeleteTags"
          ],
          "Resource": [
            "arn:aws:ec2:*:*:volume/*",
            "arn:aws:ec2:*:*:snapshot/*"
          ]
        },
        {
          "Effect": "Allow",
          "Action": [
            "ec2:CreateVolume"
          ],
          "Resource": "*",
          "Condition": {
            "StringLike": {
              "aws:RequestTag/ebs.csi.aws.com/cluster": "true"
            }
          }
        },
        {
          "Effect": "Allow",
          "Action": [
            "ec2:CreateVolume"
          ],
          "Resource": "*",
          "Condition": {
            "StringLike": {
              "aws:RequestTag/CSIVolumeName": "*"
            }
          }
        },
        {
          "Effect": "Allow",
          "Action": [
            "ec2:DeleteVolume"
          ],
          "Resource": "*",
          "Condition": {
            "StringLike": {
              "ec2:ResourceTag/ebs.csi.aws.com/cluster": "true"
            }
          }
        },
        {
          "Effect": "Allow",
          "Action": [
            "ec2:DeleteVolume"
          ],
          "Resource": "*",
          "Condition": {
            "StringLike": {
              "ec2:ResourceTag/CSIVolumeName": "*"
            }
          }
        },
        {
          "Effect": "Allow",
          "Action": [
            "ec2:DeleteVolume"
          ],
          "Resource": "*",
          "Condition": {
            "StringLike": {
              "ec2:ResourceTag/kubernetes.io/created-for/pvc/name": "*"
            }
          }
        },
        {
          "Effect": "Allow",
          "Action": [
            "ec2:DeleteSnapshot"
          ],
          "Resource": "*",
          "Condition": {
            "StringLike": {
              "ec2:ResourceTag/CSIVolumeSnapshotName": "*"
            }
          }
        },
        {
          "Effect": "Allow",
          "Action": [
            "ec2:DeleteSnapshot"
          ],
          "Resource": "*",
          "Condition": {
            "StringLike": {
              "ec2:ResourceTag/ebs.csi.aws.com/cluster": "true"
            }
          }
        }
      ]
    })
  }

}