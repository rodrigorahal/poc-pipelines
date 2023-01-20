# Creating IAM role so that Lambda service to assume the role and access other AWS services. 
resource "aws_iam_role" "lambda_role" {
  name               = "${var.env}_iam_role_lambda_function_${var.function_name}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# IAM policy for logging from a lambda
resource "aws_iam_policy" "lambda_logging" {

  name        = "${var.env}_iam_policy_lambda_logging_function_${var.function_name}"
  path        = "/"
  description = "IAM policy for logging from a lambda"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

# Policy Attachment on the role.
resource "aws_iam_role_policy_attachment" "policy_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}

data "archive_file" "default" {
  type        = "zip"
  source_dir  = abspath("${path.module}/bootstrap/")
  output_path = abspath("${path.module}/app.zip")
}


# Create a Lambda Function
resource "aws_lambda_function" "poc_pipelines_lambda" {
  function_name = "${var.env}_${var.function_name}"
  role          = aws_iam_role.lambda_role.arn
  depends_on = [
    aws_iam_role_policy_attachment.policy_attach
  ]
  filename = abspath("${path.module}/app.zip")
  runtime  = "python3.9"
  handler  = "app.index.lambda_handler"

  source_code_hash = data.archive_file.default.output_base64sha256

  lifecycle {
    ignore_changes = [
      source_code_hash,
      last_modified,
      qualified_arn,
      qualified_invoke_arn,
      version,
      filename
    ]
  }

  publish = true
}

resource "aws_lambda_alias" "lambda_alias" {
  name             = "${var.env}_${var.function_name}_alias"
  function_name    = aws_lambda_function.poc_pipelines_lambda.function_name
  function_version = "1"
  depends_on = [
    aws_lambda_function.poc_pipelines_lambda
  ]

  lifecycle {
    ignore_changes = [function_version, routing_config]
  }

}
