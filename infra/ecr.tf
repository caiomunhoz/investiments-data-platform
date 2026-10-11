data "aws_ecr_image" "ingest_binance_trades" {
  repository_name = aws_ecr_repository.lambda_ingest_binance_trades.name
  most_recent     = true
}

resource "aws_ecr_repository" "lambda_ingest_binance_trades" {
  name                 = "investments-data-platform/lambda-ingest-binance-trades"
  image_tag_mutability = "IMMUTABLE_WITH_EXCLUSION"

  image_tag_mutability_exclusion_filter {
    filter_type = "WILDCARD"
    filter      = "latest"
  }

  image_scanning_configuration {
    scan_on_push = true
  }
}