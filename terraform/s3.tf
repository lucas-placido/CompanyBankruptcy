# S3 bucket
resource "aws_s3_bucket" "tf-bucket" {
  bucket = "tf-s3-kinesis-firehose"

  tags = {
    Name = "tf-kinesis-firehose-destination"
    Environment = "Dev"
  }
}