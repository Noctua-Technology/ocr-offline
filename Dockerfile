
FROM python:3.12-slim

ARG HF_TOKEN

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    ffmpeg \
    libsm6 \
    libxext6 \
    ccache \
    git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

RUN python -m pip install --no-cache-dir uv huggingface_hub

COPY ./scripts ./scripts
RUN ./scripts/download_models.sh $HF_TOKEN

# COPY ./models ./models
COPY ./src ./src
COPY pyproject.toml uv.lock ./

RUN uv sync

RUN git clone https://github.com/vllm-project/vllm.git

WORKDIR /app/vllm

RUN git checkout v0.15.1

RUN uv pip install -r requirements/cpu.txt --index-strategy unsafe-best-match
RUN uv pip install -e .

WORKDIR /app

ENTRYPOINT [ "./scripts/run.sh" ]
