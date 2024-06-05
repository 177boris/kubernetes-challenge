##################################################################################
# EKS configuration
##################################################################################

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name                             = local.name
  cluster_version                          = local.cluster_version
  cluster_endpoint_public_access           = true
  enable_cluster_creator_admin_permissions = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  cluster_addons = {
    vpc-cni = {
      most_recent = true
    }
    amazon-cloudwatch-observability = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    # coredns = {
    #   most_recent = true
    # }
    # adot = {
    #   most_recent = true
    # }
  }

  eks_managed_node_group_defaults = {
    ami_type       = "AL2_x86_64"
    instance_types = ["t3.medium"]
  }

  eks_managed_node_groups = {
    green = {
      name = "green-node-group"

      instance_types = ["t3.medium"]

      min_size     = 1
      max_size     = 5
      desired_size = 2
    }

    blue = {
      name = "blue-node-group"

      instance_types = ["t3.medium"]

      min_size     = 1
      max_size     = 5
      desired_size = 2
    }
    #     iam_role_additional_policies = [
    # "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
    # ]
  }
}

resource "aws_iam_role_policy_attachment" "CloudwatchAgent" {
  for_each = module.eks.eks_managed_node_groups

  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  role       = each.value.iam_role_name
}

resource "helm_release" "metrics_server" {
  name = "metrics-server"

  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  namespace  = "kube-system"
  version    = "3.12.1"

  values = [file("${path.module}/metrics-server.yaml")] 
            # [templatefile("${path.module}/metrics-server.yaml", {
            #     securePort       = 10250,
            #     metricResolution = "15s" })] 

  depends_on = [module.eks.eks_managed_node_groups]
}
