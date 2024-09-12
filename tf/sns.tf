resource "aws_sns_topic" "telegram" {
  name = var.project_name
}

resource "aws_sns_topic_subscription" "telegram" {
  topic_arn = aws_sns_topic.telegram.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.telegram.arn
}