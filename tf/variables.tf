variable "region" {
  type        = string
  description = "AWS region to deploy the application in"
}

variable "project_name" {
  type        = string
  description = "Name of the project for this application"
}

variable "runtime" {
  type        = string
  description = "The runtime for the Lambda function"
}