from urllib.parse import urlsplit, parse_qsl, urlencode, urlunsplit
from base64 import b64encode


from dlt.common.configuration import configspec
from dlt.sources.helpers.rest_client.auth import AuthConfigBase
from cryptography.hazmat.primitives import serialization


@configspec
class BinanceAuth(AuthConfigBase):
    def __init__(self, api_key: str, private_key: str):
        self.api_key = api_key
        self.private_key = serialization.load_pem_private_key(
            private_key.encode(), password=None
        )

    def __call__(self, request):
        url = urlsplit(request.url)

        query = urlencode(sorted(parse_qsl(url.query)))

        request.url = urlunsplit(
            url._replace(query=f"{query}&signature={self._sign(query)}")
        )
        request.headers["X-MBX-APIKEY"] = self.api_key

        return request

    def _sign(self, payload: str) -> str:
        return b64encode(self.private_key.sign(payload.encode())).decode()
