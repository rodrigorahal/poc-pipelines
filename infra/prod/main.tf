module "lambda_function" {
  source        = "../modules/lambda"
  env           = "prod"
  function_name = "poc_pipelines_lambda_2"
}

module "codedeploy" {
  source                 = "../modules/codedeploy"
  env                    = "prod"
  deployment_config_name = "CodeDeployDefault.LambdaLinear10PercentEvery1Minute"
  function_name          = "poc_pipelines_lambda_2"
  rollback_enabled       = true
}
