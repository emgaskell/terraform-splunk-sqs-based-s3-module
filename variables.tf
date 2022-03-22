variable "region" {
  type        = string
  default     = "eu-west-2"
  description = "Region in which to create resources."
}

variable "notifier_sqs_name" {
  type        = string
  default     = "notifier_sqs"
  description = "Name of the SQS Queue."
}

variable "notifier_sqs_settings" {
  type = object({
    delay_seconds              = number
    max_message_size           = number
    message_retention_seconds  = number
    receive_wait_time_seconds  = number
    visibility_timeout_seconds = number
  })
  default = {
    delay_seconds              = 0
    max_message_size           = 262144
    message_retention_seconds  = 86400
    receive_wait_time_seconds  = 0
    visibility_timeout_seconds = 300
  }
  description = "Object of settings for timeouts of the SQS queue."
}

variable "notifier_sqs_dl_settings" {
  type = object({
    delay_seconds              = number
    max_message_size           = number
    message_retention_seconds  = number
    receive_wait_time_seconds  = number
    visibility_timeout_seconds = number
  })
  default = {
    delay_seconds              = 0
    max_message_size           = 262144
    message_retention_seconds  = 86400
    receive_wait_time_seconds  = 0
    visibility_timeout_seconds = 300
  }
  description = "Object of settings for timeouts of the SQS queue."
}

variable "notifier_sns_name" {
  type        = string
  default     = "notifier_sns"
  description = "name of the SNS topic which the SQS Queue subscribes to."
}

variable "s3_bucket_name" {
  type        = string
  description = "Name of the existing S3 bucket where the logs are lodged."
}

variable "s3_bucket_arn" {
  type        = string
  description = "ARN of the existing S3 bucket where the logs are lodged."
}

variable "consumer_role_name" {
  type        = string
  default     = "splunk_sqs_s3_access"
  description = "Name of the consumer role to be applied to the Splunk instance."
}

variable "tags" {
  type = map(any)
  default = {
    environment = "dev"
  }
  description = "Tags to assign to the resources."
}