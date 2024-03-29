resource "aws_kms_key" "eks" {
  description             = "EKS Secret Encryption Key"
  deletion_window_in_days = 7
  enable_key_rotation     = true
}

module "eks" {
  source       = "registry.terraform.io/terraform-aws-modules/eks/aws"
  cluster_name = var.cluster_name

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  vpc_id     = var.vpc_id
  subnet_ids = var.subnets

  #Do not let this module create a security group for you
  #EKS networking is 💩💩💩 and wont detect your svc ports

  create_cluster_security_group = false
  create_node_security_group    = false

  cluster_security_group_id = aws_security_group.fully_open.id
  node_security_group_id    = aws_security_group.fully_open.id

  aws_auth_fargate_profile_pod_execution_role_arns = [aws_iam_role.eks-cluster.arn]

  #  create_aws_auth_configmap = true
  manage_aws_auth_configmap = true
  aws_auth_users = [
    {
      userarn  = var.aws_user_eks
      username = "admin"
      groups   = ["system:masters"]
    },
    {
      userarn  = var.aws_user_eks
      username = "AWSAdministratorAccess"
      groups   = ["system:masters"]
    },
  ]

  aws_auth_roles = [
    {
      rolearn  = aws_iam_role.eks-cluster.arn
      username = "admin"
      groups   = ["system:masters"]
    },
    {
      rolearn  = var.aws_role_eks
      username = "AWSAdministratorAccess"
      groups   = ["system:masters"]
    }
  ]

  cluster_addons = {
    # Note: https://docs.aws.amazon.com/eks/latest/userguide/fargate-getting-started.html#fargate-gs-coredns
    coredns = {
      resolve_conflicts = "OVERWRITE"
    }
    kube-proxy = {
      resolve_conflicts = "OVERWRITE"
    }
    vpc-cni = {
      resolve_conflicts = "OVERWRITE"
    }
    aws-ebs-csi-driver = {
      resolve_conflicts = "OVERWRITE"
    }

  }

  cluster_encryption_config = [{
    provider_key_arn = aws_kms_key.eks.arn
    resources        = ["secrets"]
  }]

  # You require a node group to schedule coredns which is critical for running correctly internal DNS.
  # If you want to use only fargate you must follow docs `(Optional) Update CoreDNS`
  # available under https://docs.aws.amazon.com/eks/latest/userguide/fargate-getting-started.html
  # This cannot be done via Terraform right now unless you create your own CoreDNS image and use it.

  eks_managed_node_groups = {
    az1 = {
      subnet_ids     = [element(var.subnets, 0)]
      min_size       = var.eks_config.az1.min_size
      max_size       = var.eks_config.az1.max_size
      desired_size   = var.eks_config.az1.desired_size
      instance_types = var.eks_config.az1.instance_types
      capacity_type  = var.eks_config.az1.capacity_type
    }
    az2 = {
      subnet_ids     = [element(var.subnets, 1)]
      min_size       = var.eks_config.min_size
      max_size       = var.eks_config.max_size
      desired_size   = var.eks_config.desired_size
      instance_types = var.eks_config.instance_types
      capacity_type  = var.eks_config.capacity_type
    }
    az3 = {
      subnet_ids     = [element(var.subnets, 2)]
      min_size       = var.eks_config.min_size
      max_size       = var.eks_config.max_size
      desired_size   = var.eks_config.desired_size
      instance_types = var.eks_config.instance_types
      capacity_type  = var.eks_config.capacity_type
    }
  }

  # Persistent volumes via EBS will not work on Fargate for now
  # https://github.com/aws/containers-roadmap/issues/1113
  # Once this functionality has been included in the AWS EKS API, we can enable it by uncommenting out the below
  # This will schedule all containers on Fargate from then on (cheaper and more efficient)

  # Additionally coredns does not run on Fargate without patching and this is currently not working via Terraform
  # This means nodes on Fargate and the Managed Node cannot talk to each other 💩

  #  fargate_profiles = {
  #    default = {
  #      name = "default"
  #      selectors = [
  #        {
  #          namespace = "default",
  #          labels = {
  #            aws-schedule = "fargate"
  #          }
  #        }
  #      ]
  #
  #      tags = {
  #        Owner = "default"
  #      }
  #
  #      timeouts = {
  #        create = "20m"
  #        delete = "20m"
  #      }
  #    }
  #  }
}

module "vpc_cni_irsa" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name             = "vpc_cni"
  attach_vpc_cni_policy = true
  vpc_cni_enable_ipv4   = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-node"]
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}