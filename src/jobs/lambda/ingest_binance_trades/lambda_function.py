from ingestion.binance import pipeline


def lambda_handler(event, context):
    pipeline.run(
        symbols=[
            "BTCBRL",
            "ETHBRL",
            "SOLBRL",
        ]
    )
