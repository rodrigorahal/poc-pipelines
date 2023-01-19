module "iam_github_oidc_provider" {
  source = "terraform-aws-modules/iam/aws//modules/iam-github-oidc-provider"
}

module "iam_github_oidc_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-github-oidc-role"

  subjects = ["rodrigorahal/poc-pipelines:*"]

  policies = {
    AWSLambdaRole               = "arn:aws:iam::aws:policy/service-role/AWSLambdaRole"
    AWSLambda_FullAccess        = "arn:aws:iam::aws:policy/AWSLambda_FullAccess"
    AWSCodeDeployDeployerAccess = "arn:aws:iam::aws:policy/AWSCodeDeployDeployerAccess"
  }
}
