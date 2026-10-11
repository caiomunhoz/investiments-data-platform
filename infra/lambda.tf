data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "lambda_ingestion_policy" {
  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject",
      "s3:GetObjectAttributes",
      "s3:ListBucket"
    ]
    resources = [
      aws_s3_bucket.data_lakehouse_bucket.arn,
      "${aws_s3_bucket.data_lakehouse_bucket.arn}/*"
    ]
  }

  statement {
    effect    = "Allow"
    actions   = ["ecr:BatchGetImage", "ecr:GetDownloadUrlForLayer"]
    resources = [aws_ecr_repository.lambda_ingest_binance_trades.arn]
  }

  statement {
    effect    = "Allow"
    actions   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["arn:aws:logs:*:*:*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["secretsmanager:GetSecretValue"]
    resources = ["arn:aws:secretsmanager:*:*:secret:dlt/*"]
  }
}

resource "aws_iam_role" "lambda_ingestion_role" {
  name               = "investmentsDataPlatformLambdaIngestionRole"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

resource "aws_iam_role_policy" "lambda_ingestion_role_policy" {
  name   = "investmentsDataPlatformLambdaIngestionPolicy"
  role   = aws_iam_role.lambda_ingestion_role.id
  policy = data.aws_iam_policy_document.lambda_ingestion_policy.json
}

resource "aws_lambda_function" "ingest_binance_trades_function" {
  function_name = "investments-data-platform-ingest-binance-trades"
  package_type  = "Image"
  timeout       = 60
  image_uri     = "${aws_ecr_repository.lambda_ingest_binance_trades.repository_url}:${var.ingest_binance_trades_image_tag}"
  role          = aws_iam_role.lambda_ingestion_role.arn
  publish       = true
}