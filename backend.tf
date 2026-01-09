terraform {
  backend "s3" {
    bucket         = "cicd-aws-eks-fargate-node-tfstate-897722677427-us-east-1"
    key            = "envs/dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "cicd-aws-eks-fargate-node-tflock"
    encrypt        = true
  }
}
