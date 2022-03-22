/* SQS Queue */
resource "aws_sqs_queue" "notifier_sqs" {
  name                       = var.notifier_sqs_name
  delay_seconds              = var.notifier_sqs_settings.delay_seconds
  message_retention_seconds  = var.notifier_sqs_settings.message_retention_seconds
  receive_wait_time_seconds  = var.notifier_sqs_settings.receive_wait_time_seconds
  visibility_timeout_seconds = var.notifier_sqs_settings.visibility_timeout_seconds
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.notifier_sqs_dl.arn
    maxReceiveCount     = 4
  })
  tags = var.tags
}

resource "aws_sqs_queue_policy" "notifier_sqs" {
  queue_url = aws_sqs_queue.notifier_sqs.url
  policy    = data.aws_iam_policy_document.notifier_sqs_sns_policy.json
}

/* Dead Letter SQS Queue */
resource "aws_sqs_queue" "notifier_sqs_dl" {
  name                       = "${var.notifier_sqs_name}_dl"
  delay_seconds              = var.notifier_sqs_dl_settings.delay_seconds
  max_message_size           = var.notifier_sqs_dl_settings.max_message_size
  message_retention_seconds  = var.notifier_sqs_dl_settings.message_retention_seconds
  receive_wait_time_seconds  = var.notifier_sqs_dl_settings.receive_wait_time_seconds
  visibility_timeout_seconds = var.notifier_sqs_dl_settings.visibility_timeout_seconds
  tags                       = var.tags
}

resource "aws_sqs_queue_policy" "sqs_dl" {
  queue_url = aws_sqs_queue.notifier_sqs_dl.url
  policy    = data.aws_iam_policy_document.notifier_sqs_dl_policy.json
}

/* SNS Topic and Access */
resource "aws_sns_topic" "notifier_sns" {
  name = var.notifier_sns_name
  tags = var.tags
}

resource "aws_sns_topic_policy" "sns_access" {
  arn    = aws_sns_topic.notifier_sns.arn
  policy = data.aws_iam_policy_document.notifier_sns_topic_policy.json
}

resource "aws_sns_topic_subscription" "notifier_sqs_subscribe" {
  topic_arn = aws_sns_topic.notifier_sns.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.notifier_sqs.arn
}

/* S3 Bucket Notification */
resource "aws_s3_bucket_notification" "notifier_notification" {
  bucket     = var.s3_bucket_name
  depends_on = [aws_sns_topic.notifier_sns, aws_sns_topic_policy.sns_access]
  topic {
    topic_arn = aws_sns_topic.notifier_sns.arn
    events    = ["s3:ObjectCreated:*"]
  }
}

/* Consumer Role Policies */
resource "aws_iam_policy" "sqs_rld" {
  name        = "${var.notifier_sqs_name}_sqs_rld"
  description = "List access to SQS Queues. Read and delete message access to ${var.notifier_sqs_name}"
  policy      = data.aws_iam_policy_document.sqs_rld.json
}

resource "aws_iam_policy" "s3_rl" {
  name        = "${var.s3_bucket_name}_s3_rl"
  description = "List access to S3. Read access to the S3 bucket ${var.s3_bucket_name}"
  policy      = data.aws_iam_policy_document.s3_rl.json
}


/* Consumer IAM Role */
resource "aws_iam_role" "notifier_sqs_based_s3" {
  name = var.consumer_role_name
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_instance_profile" "test_profile" {
  name = var.consumer_role_name
  role = aws_iam_role.notifier_sqs_based_s3.name
}

resource "aws_iam_policy_attachment" "splunk_sqs_access" {
  name       = "${var.consumer_role_name}-sqs_access"
  roles      = [aws_iam_role.notifier_sqs_based_s3.name]
  policy_arn = aws_iam_policy.sqs_rld.arn
}

resource "aws_iam_policy_attachment" "splunk_s3_access" {
  name       = "${var.consumer_role_name}-s3_access"
  roles      = [aws_iam_role.notifier_sqs_based_s3.name]
  policy_arn = aws_iam_policy.s3_rl.arn
}