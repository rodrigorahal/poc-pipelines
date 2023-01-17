module "lambda_function" {
  source = "../modules/lambda"

  env = "dev"

  function_name = "poc_pipelines_lambda"
}

module "codedeploy" {
  source = "../modules/codedeploy"

  env = "dev"

  deployment_config_name = "CodeDeployDefault.LambdaAllAtOnce"

  function_name = "poc_pipelines_lambda"

  rollback_enabled = false
}