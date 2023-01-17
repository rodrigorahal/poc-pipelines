resource "aws_iam_role" "codedeploy_deployment_group_iam_role" {
  name = "${var.env}_iam_role_codedeploy_deployment_group"

  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Action" : "sts:AssumeRole",
          "Principal" : {
            "Service" : "codedeploy.amazonaws.com"
          },
          "Effect" : "Allow",
        }
      ]
    }
  )
}

resource "aws_iam_role_policy_attachment" "codedeploy_deployment_group_iam_policy" {
  role       = aws_iam_role.codedeploy_deployment_group_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRoleForLambdaLimited"
}

resource "aws_cloudwatch_metric_alarm" "rollback_alarm" {
  alarm_name                = "${var.env}-lambda-rollback-alarm"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "Errors"
  namespace                 = "AWS/Lambda"
  period                    = "60"
  statistic                 = "SampleCount"
  threshold                 = "1"
  alarm_description         = "This metric monitors lambda errors"
  insufficient_data_actions = []

  dimensions = {
    FunctionName = "${var.env}_${var.function_name}"
    Resource     = "${var.env}_${var.function_name}"
  }
}

resource "aws_codedeploy_app" "codedeploy_app" {
  compute_platform = "Lambda"
  name             = "${var.env}_CodeDeployApp"
}

resource "aws_codedeploy_deployment_group" "codedeploy_deployment_group" {
  app_name              = aws_codedeploy_app.codedeploy_app.name
  deployment_group_name = "${var.env}_CodeDeployDeploymentGroup"
  service_role_arn      = aws_iam_role.codedeploy_deployment_group_iam_role.arn

  deployment_config_name = var.deployment_config_name

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  auto_rollback_configuration {
    enabled = var.rollback_enabled
    events  = ["DEPLOYMENT_FAILURE", "DEPLOYMENT_STOP_ON_ALARM"]
  }

  alarm_configuration {
    alarms  = [aws_cloudwatch_metric_alarm.rollback_alarm.alarm_name]
    enabled = var.rollback_enabled
  }
}
