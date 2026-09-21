resource "aws_ecr_repository" "lambda_ingest_binance_trades" {
  name                 = "investiments-data-platform/lambda-ingest-binance-trades"
  image_tag_mutability = "IMMUTABLE_WITH_EXCLUSION"

  image_tag_mutability_exclusion_filter {
    filter_type = "WILDCARD"
    filter      = "latest"
  }

  image_scanning_configuration {
    scan_on_push = true
  }
}