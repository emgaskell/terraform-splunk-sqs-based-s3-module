# Splunk SQS Based S3 Terraform Module

## Overview

This module creates the resources in AWS required to set up the Splunk SQS based S3 input. 

## Prerequisites

- S3 bucket - An S3 bucket in which logs are or will be lodged.
- Splunk instance - An EC2 instance running Splunk.

## Resources Created

### Resources

| Resource | Description |
|---|---|
| SQS Queue | SQS Queue for Splunk to poll. |
| Dead Letter SQS Queue | Dead letter SQS Queue for the above queue. |
| SNS Topic | SNS Topic to receive notifications from the S3 bucket. |
| SNS Topic Subscription | Subscription allowing the SQS Queue to subscribe to the SNS Topic |
| AWS S3 Bucket Notification | Notifier on the S3 bucket whenever an object is created or updated. |

### IAM

| Resource | Description |
|---|---|
| SQS Queue Access Policy | Allows the SQS Queue to subscribe to the SNS Topic. |
| SQS Queue Access Policy - dead letter | Allows the dead letter queue to access the other SQS Queue. |
| IAM Policy - SQS | Allows list access to all SQS Queues and read and delete message access to the SQS Queue created usign this code. |
| IAM Policy - S3 | Allows read, and list access to the S3 bucket specified. |
| AWS IAM Role | IAM Role for EC2. This has the two policies above attached. |

## Terraform Variables

| Name | Type | Default | Description |
|---|---|---|---|
| region | String | eu-west-2 | AWS Region in which to deploy resources. |
| notifier_sqs_name | String | notifier_sqs | Name of the SQS Queue. |
| notifier_sqs_queue_settings | object({delay_seconds              = number max_message_size           = number message_retention_seconds  = number receive_wait_time_seconds  = number visibility_timeout_seconds = number}) | { delay_seconds              = 0 max_message_size           = 262144 message_retention_seconds  = 86400 receive_wait_time_seconds  = 0 visibility_timeout_seconds = 300 } |
| notifier_sqs_queue_dl_settings | object({delay_seconds              = number max_message_size           = number message_retention_seconds  = number receive_wait_time_seconds  = number visibility_timeout_seconds = number}) | { delay_seconds              = 0 max_message_size           = 262144 message_retention_seconds  = 86400 receive_wait_time_seconds  = 0 visibility_timeout_seconds = 300 } |
| notifier_sns_name | String | notifier_sns | Name of the SNS Topic. |
| s3_bucket_name | String | | Name of the existing S3 bucket. |
| s3_bucket_arn | String | | ARN of the existing ARN |
| consumer_role_name | String | splunk_sqs_s3_access | Name of the IAM Role to attach to the Splunk instance. |
| tags | Map | Map of KV pairs to tag resources with. |