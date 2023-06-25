resource "aws_instance" "tf-ec2-instance" {
  ami           = "ami-022e1a32d3f742bd8" # Amazon Machine Image
  instance_type = "t2.micro"

  iam_instance_profile = aws_iam_instance_profile.ec2-profile.name
  vpc_security_group_ids = [aws_security_group.my-security-group.id]
  key_name = "key-pair"
  user_data = file("ec2-commands.sh")

  depends_on = [aws_iam_role.ec2-role]
  tags = {
    Name = "tf-RUAPI"
    ec2-RUAPI = "ec2-RandomUserAPI"
  }
}

resource "aws_security_group" "my-security-group" {
  name        = "my-security-group"
  description = "Allow inbound SSH and outbound internet access"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    ec2-RUAPI = "Network to request data from Random User API"
  }
}

resource "aws_key_pair" "tf-key-pair" {
  key_name = "key-pair"
  public_key = file("key-pair.pub")
}


resource "aws_iam_role" "ec2-role" {
  name = "tf-ec2-role"
  assume_role_policy = jsonencode(
    {
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
  }
  )

  tags = {
    ec2-RUAPI = "Instance role to get access keys and put records on kinesis"
  }
}

resource "aws_iam_policy" "ec2-iam-policy" {
  name = "ec2-ReadAccess-to-IAM"
  description = "Access to IAM users, PutRecords on Kinesis and CloudWatchAgentServerPolicy"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "iam:GenerateCredentialReport",
        "iam:GenerateServiceLastAccessedDetails",
        "iam:Get*",
        "iam:List*",
        "iam:SimulateCustomPolicy",
        "iam:SimulatePrincipalPolicy"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action":[
        "kinesis:PutRecord",
        "kinesis:UpdateShardCount",
        "kinesis:DescribeLimits",
        "kinesis:DescribeStream",
        "kinesis:ListShards",
        "kinesis:UpdateShardCount"        
      ],
      "Resource": "${aws_kinesis_stream.kinesis-stream.arn}"
    },
    {
      "Effect" : "Allow",
      "Action" : [
        "cloudwatch:PutMetricData",
        "ec2:DescribeVolumes",
        "ec2:DescribeTags",
        "logs:PutLogEvents",
        "logs:DescribeLogStreams",
        "logs:DescribeLogGroups",
        "logs:CreateLogStream",
        "logs:CreateLogGroup",
        "logs:PutRetentionPolicy"
      ],
      "Resource" : "*"
    },
    {
      "Effect" : "Allow",
      "Action" : [
        "ssm:GetParameter",
        "ssm:PutParameter"
      ],
      "Resource" : "arn:aws:ssm:*:*:parameter/AmazonCloudWatch-*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "attach-ec2-policy-to-ec2-role" {
  role = aws_iam_role.ec2-role.name
  policy_arn = aws_iam_policy.ec2-iam-policy.arn
}

resource "aws_iam_instance_profile" "ec2-profile" {
  name = "tf-ec2-profile"
  role = aws_iam_role.ec2-role.name
}