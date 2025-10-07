####################################
# DATA SOURCE: Availability Zones
####################################
data "aws_availability_zones" "available" {
  state = "available"
}

####################################
# MODULE: VPC
####################################
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.2"

  name = "${var.cluster_name}-vpc"
  cidr = var.vpc_cidr

  azs             = slice(data.aws_availability_zones.available.names, 0, 2)
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    "Project"     = "terraform-eks"
    "Environment" = "dev"
  }
}

####################################
# MODULE: EKS Cluster
####################################
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.8.5"

  cluster_name    = var.cluster_name
  cluster_version = "1.29"
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnets

  eks_managed_node_groups = var.eks_managed_node_groups

  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = false

  tags = {
    "Project"     = "terraform-eks"
    "Environment" = "dev"
  }
}

