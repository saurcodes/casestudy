resource "aws_eks_cluster" "zantac" {
  name     = var.eks_cluster_name
  role_arn = aws_iam_role.eks_cluster.arn
  version  = var.kubernetes_version

  vpc_config {
    subnet_ids              = aws_subnet.private[*].id
    endpoint_private_access = true
    endpoint_public_access  = true
    security_group_ids      = [aws_security_group.eks_cluster.id]
  }

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy,
    aws_iam_role_policy_attachment.eks_vpc_resource_controller,
    aws_cloudwatch_log_group.eks
  ]

  tags = {
    Name        = var.eks_cluster_name
    Environment = var.environment
  }
}

resource "aws_cloudwatch_log_group" "eks" {
  name              = "/aws/eks/${var.eks_cluster_name}/cluster"
  retention_in_days = 30

  tags = {
    Name        = "${var.eks_cluster_name}-logs"
    Environment = var.environment
  }
}

resource "aws_security_group" "eks_cluster" {
  name        = "${var.environment}-eks-cluster-sg"
  description = "Security group for EKS cluster"
  vpc_id      = aws_vpc.zantac_vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.environment}-eks-cluster-sg"
    Environment = var.environment
  }
}

# EKS Node Groups
resource "aws_eks_node_group" "zantac" {
  for_each = {
    general    = { instance_type = "m5.large", desired_size = 2, min_size = 2, max_size = 4 },
    middleware = { instance_type = "c5.large", desired_size = 2, min_size = 2, max_size = 4 },
    backend    = { instance_type = "r5.large", desired_size = 2, min_size = 2, max_size = 4 }
  }

  cluster_name    = aws_eks_cluster.zantac.name
  node_group_name = "${var.environment}-${each.key}"
  node_role_arn   = aws_iam_role.eks_node.arn
  subnet_ids      = aws_subnet.private[*].id
  instance_types  = [each.value.instance_type]

  scaling_config {
    desired_size = each.value.desired_size
    max_size     = each.value.max_size
    min_size     = each.value.min_size
  }

  update_config {
    max_unavailable = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.eks_container_registry
  ]

  tags = {
    Name        = "${var.environment}-${each.key}-node-group"
    Environment = var.environment
  }
}

# Fargate Profiles for Serverless Workloads
resource "aws_eks_fargate_profile" "analytics" {
  cluster_name           = aws_eks_cluster.zantac.name
  fargate_profile_name   = "analytics"
  pod_execution_role_arn = aws_iam_role.fargate_pod_execution.arn
  subnet_ids             = aws_subnet.private[*].id

  selector {
    namespace = "analytics"
    labels = {
      workload-type = "serverless"
    }
  }

  tags = {
    Name        = "${var.environment}-analytics-fargate"
    Environment = var.environment
  }
}