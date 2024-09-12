#Create Lambda function
resource "aws_lambda_function" "telegram" {
  filename         = data.archive_file.telegram.output_path
  function_name    = var.project_name
  role             = aws_iam_role.lambda.arn
  handler          = "main.notify"
  source_code_hash = data.archive_file.telegram.output_base64sha256
  runtime          = var.runtime
  layers           = [data.aws_lambda_layer_version.layer.arn, "arn:aws:lambda:eu-west-1:015030872274:layer:AWS-Parameters-and-Secrets-Lambda-Extension-Arm64:11"]
  architectures    = ["arm64"]
}

#Add SNS invoke permission to Lambda
resource "aws_lambda_permission" "sns" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.telegram.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.telegram.arn
}

#Create IAM role for Lambda function
resource "aws_iam_role" "lambda" {
  name = "${var.project_name}_lambda"

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

  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"]
  inline_policy {
    name   = "ssm"
    policy = data.aws_iam_policy_document.ssm.json
  }
}

data "aws_iam_policy_document" "ssm" {
  statement {
    actions = ["ssm:GetParameter", "kms:Decrypt"]
    resources = [
      "arn:aws:ssm:${var.region}:${data.aws_caller_identity.current.account_id}:parameter/telegram/*",
      data.aws_kms_key.ssm.arn
    ]
  }
}