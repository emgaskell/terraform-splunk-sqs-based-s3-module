/* Current AWS Account Details */
data "aws_caller_identity" "current" {}

/* SNS Topic Access Policy */
data "aws_iam_policy_document" "notifier_sns_topic_policy" {
  policy_id = "__default_policy_ID"
  version   = "2008-10-17"
  statement {
    actions = [
      "sns:GetTopicAttributes",
      "sns:SetTopicAttributes",
      "sns:AddPermission",
      "sns:RemovePermission",
      "sns:DeleteTopic",
      "sns:Subscribe",
      "sns:ListSubscriptionsByTopic",
      "sns:Publish",
      "sns:Receive",
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:SourceOwner"
      values = [
        data.aws_caller_identity.current.account_id,
      ]
    }
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*", ]
    }
    resources = [
      aws_sns_topic.notifier_sns.arn,
    ]
    sid = "__default_statement_ID"
  }
  statement {
    actions = [
      "sns:Publish",
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]

    }
    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = [var.s3_bucket_arn]
    }
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*", ]
    }
    resources = [
      aws_sns_topic.notifier_sns.arn,
    ]
    sid = "s3-sns-sid"
  }
  statement {
    actions = [
      "sns:Subscribe",
    ]
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root",
      ]
    }
    resources = [
      aws_sqs_queue.notifier_sqs.arn,
    ]
    sid = "sqs-subscribe"
  }

}

/* SQS Queue Access Policy */
data "aws_iam_policy_document" "notifier_sqs_sns_policy" {
  version   = "2008-10-17"
  policy_id = "__default_policy_ID"
  statement {
    actions = [
      "SQS:*",
    ]
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root",
      ]
    }
    resources = [
      aws_sqs_queue.notifier_sqs.arn,
    ]
    sid = "__owner_statement-cribl"
  }
  statement {
    sid = "topic-subscription-${var.notifier_sns_name}"
    actions = [
      "SQS:SendMessage",
    ]
    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values = [
        aws_sns_topic.notifier_sns.arn,
      ]
    }
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*", ]
    }
    resources = [
      aws_sqs_queue.notifier_sqs.arn,
    ]

  }
}

/* Dead Letter Queue Access Policy */
data "aws_iam_policy_document" "notifier_sqs_dl_policy" {
  version   = "2008-10-17"
  policy_id = "__default_policy_ID"
  statement {
    actions = [
      "SQS:*",
    ]
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root",
      ]
    }
    resources = [
      aws_sqs_queue.notifier_sqs_dl.arn,
    ]
    sid = "__owner_statement"
  }
}

/* Consumer Role S3 access */
data "aws_iam_policy_document" "s3_rl" {
  version = "2012-10-17"
  statement {
    actions = [
      "s3:GetLifecycleConfiguration",
      "s3:GetBucketTagging",
      "s3:GetInventoryConfiguration",
      "s3:GetObjectVersionTagging",
      "s3:GetBucketLogging",
      "s3:GetAccelerateConfiguration",
      "s3:GetBucketPolicy",
      "s3:GetObjectVersionTorrent",
      "s3:GetObjectAcl",
      "s3:GetEncryptionConfiguration",
      "s3:GetBucketObjectLockConfiguration",
      "s3:GetBucketRequestPayment",
      "s3:GetObjectVersionAcl",
      "s3:GetObjectTagging",
      "s3:GetMetricsConfiguration",
      "s3:GetBucketOwnershipControls",
      "s3:GetBucketPublicAccessBlock",
      "s3:GetBucketPolicyStatus",
      "s3:GetObjectRetention",
      "s3:GetBucketWebsite",
      "s3:GetBucketVersioning",
      "s3:GetBucketAcl",
      "s3:GetObjectLegalHold",
      "s3:GetBucketNotification",
      "s3:GetReplicationConfiguration",
      "s3:GetObject",
      "s3:GetObjectTorrent",
      "s3:GetBucketCORS",
      "s3:GetAnalyticsConfiguration",
      "s3:GetObjectVersionForReplication",
      "s3:GetBucketLocation",
      "s3:GetObjectVersion",
    ]
    effect = "Allow"
    resources = [
      var.s3_bucket_arn,
      "${var.s3_bucket_arn}/*",
    ]
    sid = "VisualEditor0"
  }
  statement {
    actions = [
      "s3:GetAccessPoint",
      "s3:GetAccountPublicAccessBlock",
      "s3:ListAccessPoints",
    ]
    effect    = "Allow"
    resources = ["*"]
    sid       = "VisualEditor1"
  }

}

/* Consumer SQS Access */
data "aws_iam_policy_document" "sqs_rld" {
  statement {
    actions = [
      "SQS:DeleteMessage",
      "SQS:GetQueueUrl",
      "SQS:ListDeadLetterSourceQueues",
      "SQS:ReceiveMessage",
      "SQS:GetQueueAttributes",
      "SQS:ListQueueTags"
    ]
    effect = "Allow"
    resources = [
      aws_sqs_queue.notifier_sqs.arn,
    ]
    sid = "VisualEditor0"
  }
  statement {
    actions = [
      "SQS:ListQueues",
    ]
    effect = "Allow"
    resources = [
      "*",
    ]
    sid = "VisualEditor1"
  }
}
