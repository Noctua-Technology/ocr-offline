
FROM vllm/vllm-openai

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

COPY ./scripts ./scripts
RUN ./scripts/download_models.sh $HF_TOKEN

# COPY ./models ./models
COPY ./src ./src
COPY pyproject.toml uv.lock ./

RUN uv sync

ENTRYPOINT [ "./scripts/run.sh" ]
