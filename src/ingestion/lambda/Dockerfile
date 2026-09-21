FROM ghcr.io/astral-sh/uv:0.12.13 AS uv

FROM public.ecr.aws/lambda/python:3.12 AS builder

ENV UV_COMPILE_BYTECODE=1
ENV UV_NO_INSTALLER_METADATA=1
ENV UV_LINK_MODE=copy

RUN --mount=from=uv,source=/uv,target=/bin/uv \
    --mount=type=cache,target=/root/.cache/uv \
    --mount=type=bind,source=uv.lock,target=uv.lock \
    --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
    --mount=type=bind,source=src/ingestion/pyproject.toml,target=src/ingestion/pyproject.toml \
    uv export --frozen --package ingestion --no-emit-workspace --no-dev --no-editable -o requirements.txt && \
    uv pip install -r requirements.txt --target "${LAMBDA_TASK_ROOT}"

RUN --mount=from=uv,source=/uv,target=/bin/uv \
    --mount=type=cache,target=/root/.cache/uv \
    --mount=type=bind,source=uv.lock,target=uv.lock \
    --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
    --mount=type=bind,source=src/ingestion/pyproject.toml,target=src/ingestion/pyproject.toml \
    --mount=type=bind,source=src/ingestion/pipelines,target=src/ingestion/pipelines \
    uv export --frozen --package ingestion --no-dev --no-editable -o requirements.txt && \
    uv pip install -r requirements.txt --target "${LAMBDA_TASK_ROOT}"

FROM public.ecr.aws/lambda/python:3.12

ARG LAMBDA_FUNCTION_DIR

COPY --from=builder ${LAMBDA_TASK_ROOT} ${LAMBDA_TASK_ROOT}
COPY ./${LAMBDA_FUNCTION_DIR}/lambda_function.py ${LAMBDA_TASK_ROOT}/lambda_function.py
COPY ./src/ingestion/pipelines/.dlt/config.toml ${LAMBDA_TASK_ROOT}/.dlt/config.toml

CMD ["lambda_function.lambda_handler"]
