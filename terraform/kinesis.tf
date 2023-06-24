# KINESIS DATA STREAM
resource "aws_kinesis_stream" "kinesis-stream" {
  name             = "tf-kinesis-stream"
  shard_count      = 1
  retention_period = 24

  shard_level_metrics = [
    "IncomingBytes",
    "OutgoingBytes",
  ]

  stream_mode_details {
    stream_mode = "PROVISIONED"
  }

  tags = {
    Environment = "Dev"
  }
}

# KINESIS DATA FIREHOSE

# Creates role policy document
data "aws_iam_policy_document" "firehose_assume_role" {
  statement {    
    effect = "Allow"
    actions = ["sts:AssumeRole"]
    
    principals {
      type        = "Service"
      identifiers = ["firehose.amazonaws.com"]
    }
  }
}

# Create role with created role policy
resource "aws_iam_role" "firehose_role" {
  name               = "firehose_tf-role"
  assume_role_policy = data.aws_iam_policy_document.firehose_assume_role.json
}

# Create policy document to give permissions to firehose access resources
data "aws_iam_policy_document" "tf-firehose-permissions" {
  statement {
    effect = "Allow"
    actions = [
      "kinesis:*"
    ]
    # arn:aws:service:region:account_id:resource
    resources = [
      aws_kinesis_stream.kinesis-stream.arn
      ]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:*"
    ]
    resources = [
      aws_s3_bucket.tf-bucket.arn,
      "${aws_s3_bucket.tf-bucket.arn}/*",
      ]
  }

  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }
}

# Create policy with policy document created prevously
resource "aws_iam_policy" "tf-policy-firehose" {
  name = "tf-aim-policy-for-firehose"
  policy = data.aws_iam_policy_document.tf-firehose-permissions.json
}

# Attach policy to role
resource "aws_iam_role_policy_attachment" "attach-policy-to-firehose-role" {
  role = aws_iam_role.firehose_role.name
  policy_arn = aws_iam_policy.tf-policy-firehose.arn
}


# DATA FIREHOSE CREATION
resource "aws_kinesis_firehose_delivery_stream" "tf-kinesis-firehose" {
  name = "tf-kinesis-firehose"
  destination = "extended_s3"

  # Data Source
  kinesis_source_configuration {
    kinesis_stream_arn = aws_kinesis_stream.kinesis-stream.arn
    role_arn = aws_iam_role.firehose_role.arn
  }

  # Data Destination
  extended_s3_configuration {
    bucket_arn = aws_s3_bucket.tf-bucket.arn
    role_arn = aws_iam_role.firehose_role.arn
    buffer_interval = 60
    buffer_size = 1

    cloudwatch_logging_options {
      enabled = true
      log_group_name = "kinesis-firehose-logs"
      log_stream_name = "RandomUserAPI-logs"
    }
  }

  depends_on = [aws_iam_role.firehose_role]
}