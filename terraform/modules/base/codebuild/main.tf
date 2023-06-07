resource "aws_s3_bucket" "codebuild" {
  bucket = "codebuildbucket-${var.codebuild_project_name}"
}

resource "aws_s3_bucket_acl" "codebuild" {
  bucket = aws_s3_bucket.codebuild.id
  acl    = "private"
}

resource "aws_iam_role" "codebuild" {
  name = "codebuildrole-${var.codebuild_project_name}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "example" {
  role = aws_iam_role.codebuild.name

  policy = var.iam_policy
}

resource "aws_codebuild_project" "example" {
  name          = var.codebuild_project_name
  description   = var.codebuild_description
  build_timeout = var.build_timeout
  service_role  = aws_iam_role.codebuild.arn

  artifacts {
    type = "CODEPIPELINE" # TBD: Change it to the image especifications
  }

  cache {
    type     = "S3"
    location = aws_s3_bucket.codebuild.bucket
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/docker:17.09.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "log-group"
      stream_name = "log-stream"
    }

    s3_logs {
      status   = "ENABLED"
      location = "${aws_s3_bucket.codebuild.id}/build-log"
    }
  }

  source {
    type = "CODEPIPELINE"
  }

  vpc_config {
    vpc_id = var.vpc_id

    subnets = var.private_subnet_list

    security_group_ids = var.security_group_ids_list
  }

  tags = var.tags
}