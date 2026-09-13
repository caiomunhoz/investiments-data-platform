resource "aws_ecr_repository" "lambda_ingest_binance_trades" {
  name                 = "investiments-data-platform/lambda-ingest-binance-trades"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_lifecycle_policy" "lambda_ingest_binance_trades" {
  repository = aws_ecr_repository.lambda_ingest_binance_trades.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Expire untagged images after 14 days"
      selection = {
        tagStatus   = "untagged"
        countType   = "sinceImagePushed"
        countUnit   = "days"
        countNumber = 14
      }
      action = { type = "expire" }
    }]
  })
}
