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
}
