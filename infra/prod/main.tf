module "lambda_function" {
  source = "../modules/lambda"

  env = "prod"

  function_name = "poc_pipelines_lambda"
}