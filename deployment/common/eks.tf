variable "cluster_name" {
  default = "tada_core"
  type    = string
}

resource "aws_iam_role" "tada_eks" {
  name = "tada_eks"

  assume_role_policy = <<POLICY
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "eks.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  }
  POLICY
}


resource "aws_iam_role" "tada_eks_node_group" {
  name = "tada_eks_node_group"

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

resource "aws_iam_role_policy_attachment" "tada_eks" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.tada_eks.name
}

resource "aws_iam_role_policy_attachment" "tada_vpc" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.tada_eks.name
}

resource "aws_iam_role_policy_attachment" "tada_core_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.tada_eks_node_group.name
}

resource "aws_iam_role_policy_attachment" "tada_core_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.tada_eks_node_group.name
}

resource "aws_iam_role_policy_attachment" "tada_core_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.tada_eks_node_group.name
}

resource "aws_eks_cluster" "tada_core" {
  depends_on = [
    aws_cloudwatch_log_group.tada_core,
    aws_iam_role_policy_attachment.tada_eks,
    aws_iam_role_policy_attachment.tada_vpc,
  ]

  vpc_config {
    subnet_ids = ["subnet-9e178dc7", "subnet-344a957c", "subnet-00f85666"]
  }

  enabled_cluster_log_types = ["api", "audit"]
  name                      = "tada_core"
  role_arn                  = aws_iam_role.tada_eks.arn
}

resource "aws_cloudwatch_log_group" "tada_core" {
  name              = "/aws/eks/${var.cluster_name}/cluster"
  retention_in_days = 7
}

resource "aws_eks_node_group" "tada_core_primary_group" {
  cluster_name    = aws_eks_cluster.tada_core.name
  node_group_name = "tada_core_primary_group"
  node_role_arn   = aws_iam_role.tada_eks_node_group.arn
  subnet_ids      = ["subnet-9e178dc7", "subnet-344a957c", "subnet-00f85666"]

  scaling_config {
    desired_size = 2
    max_size     = 4
    min_size     = 2
  }

  depends_on = [
    aws_iam_role_policy_attachment.tada_core_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.tada_core_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.tada_core_AmazonEC2ContainerRegistryReadOnly,
  ]
}

output "endpoint" {
  value = aws_eks_cluster.tada_core.endpoint
}

output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.tada_core.certificate_authority[0].data
}


