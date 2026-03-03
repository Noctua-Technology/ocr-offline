
FROM python:3.12-slim

ARG HF_TOKEN

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    ffmpeg \
    libsm6 \
    libxext6 \
    ccache \
    && rm -rf /var/lib/apt/lists/*

RUN python -m pip install --no-cache-dir uv huggingface_hub

WORKDIR /app

# COPY ./models ./models
COPY ./scripts ./scripts
COPY ./src ./src
COPY ./vllm ./vllm
COPY pyproject.toml uv.lock ./

RUN python -m uv venv


RUN uv sync
RUN ./scripts/download_models.sh $HF_TOKEN

RUN cd vllm \
    uv pip install -r requirements/cpu.txt --index-strategy unsafe-best-match \
    uv pip install -e .

ENTRYPOINT [ "./scripts/run.sh" ]
