output "role_name" {
  value = aws_iam_role.notifier_sqs_based_s3.name
}

output "role_arn" {
  value = aws_iam_role.notifier_sqs_based_s3.arn
}

output "queue_name" {
  value = aws_sqs_queue.notifier_sqs.name
}

output "queue_url" {
  value = aws_sqs_queue.notifier_sqs.id
}