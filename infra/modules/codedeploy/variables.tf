variable "env" {
  type    = string
  default = "dev"
}

variable "deployment_config_name" {
  type    = string
  default = "CodeDeployDefault.LambdaAllAtOnce"
}

variable "function_name" {
  type = string
}

variable "rollback_enabled" {
  type = bool
  default = false
}
