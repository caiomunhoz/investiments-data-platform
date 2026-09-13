import pendulum
import dlt
from dlt.sources.rest_api import RESTAPIConfig, rest_api_resources

from auth import BinanceAuth


@dlt.source
def binance_source(
    symbols: list[str],
    api_key: str = dlt.secrets.value,
    private_key: str = dlt.secrets.value,
):
    config: RESTAPIConfig = {
        "client": {
            "base_url": "https://api.binance.com/api/v3",
            "auth": BinanceAuth(api_key, private_key),
        },
        "resources": [
            {
                "name": f"trades_{symbol.lower()}",
                "table_name": "trades",
                "primary_key": "id",
                "parallelized": True,
                "endpoint": {
                    "path": "myTrades",
                    "paginator": "single_page",
                    "params": {
                        "symbol": symbol,
                        "fromId": "{incremental.start_value}",
                        "limit": 1000,
                        "timestamp": pendulum.now("UTC").int_timestamp * 1000,
                    },
                    "incremental": {
                        "cursor_path": "id",
                        "initial_value": 0,
                    },
                },
            }
            for symbol in symbols
        ],
    }

    yield from rest_api_resources(config)


def run_pipeline(symbols: list[str]) -> None:
    pipeline = dlt.pipeline(
        pipeline_name="binance_pipeline",
        destination="filesystem",
        dataset_name="binance",
    )

    pipeline.run(binance_source(symbols))
