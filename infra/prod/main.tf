module "lambda_function" {
  source = "../modules/lambda"

  env = "prod"

  function_name = "poc_pipelines_lambda"
}

module "codedeploy" {
  source = "../modules/codedeploy"

  env = "prod"

  deployment_config_name = "CodeDeployDefault.LambdaLinear10PercentEvery1Minute"
}