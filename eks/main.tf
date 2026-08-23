provider "aws" {
  region = var.region
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = var.cluster_name
  kubernetes_version = var.kubernetes_version

  # Получаем VPC из terraform_remote_state
  vpc_id     = data.terraform_remote_state.vpc.outputs.vpc_id
  subnet_ids = data.terraform_remote_state.vpc.outputs.private_subnets

  endpoint_public_access = true

  # Делаем текущего AWS пользователя администратором EKS
  enable_cluster_creator_admin_permissions = true

  # EKS add-ons
  addons = {
    coredns = {}

    eks-pod-identity-agent = {
      before_compute = true
    }

    kube-proxy = {}

    vpc-cni = {
      before_compute = true
    }
  }

  # CPU workload
  eks_managed_node_groups = {
    cpu-nodes = {
      instance_types = ["t3.medium"]

      ami_type = "AL2023_x86_64_STANDARD"

      min_size     = 1
      max_size     = 2
      desired_size = 1

      labels = {
        workload = "cpu"
      }
    }

    # Отдельная node group для workload isolation.
    # GPU-инстанс здесь намеренно НЕ используется,
    # чтобы не создавать дорогую GPU-инфраструктуру.
    gpu-nodes = {
      instance_types = ["t3.small"]

      ami_type = "AL2023_x86_64_STANDARD"

      min_size     = 1
      max_size     = 1
      desired_size = 1

      labels = {
        workload = "gpu"
      }

      taints = {
        gpu-workload = {
          key    = "workload"
          value  = "gpu"
          effect = "NO_SCHEDULE"
        }
      }
    }
  }

  tags = {
    Project     = "mlops"
    Environment = "dev"
    Terraform   = "true"
  }
}
