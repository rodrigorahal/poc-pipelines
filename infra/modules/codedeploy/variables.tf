variable "env" {
  type    = string
  default = "dev"
}

variable "deployment_config_name" {
  type    = string
  default = "CodeDeployDefault.LambdaAllAtOnce"
}
