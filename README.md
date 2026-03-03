# paddle-vllm

Small FastAPI wrapper around `PaddleOCRVL` with two runtime modes:

- Local OCR backend (no vLLM server)
- vLLM-backed OCR (`--vllm`)

## Prerequisites

- Python 3.12+
- `uv`
- `git`
- `huggingface-cli` (`hf`) for model downloads

## Clone (with submodules)

This repo uses `vllm/` as a git submodule. Include it when cloning.

```bash
git clone --recurse-submodules git@github.com:Noctua-Technology/paddle-ocr-offline.git
```

If you already cloned without submodules:

```bash
git submodule update --init --recursive
```

## Setup

```bash
uv sync
```

Download OCR models:

```bash
./scripts/download_models.sh
```

## Run

Start API in local backend mode:

```bash
./scripts/run.sh
```

Start API with vLLM worker + API:

```bash
./scripts/run.sh --vllm
```

Use an existing remote/local vLLM server URL instead of starting one:

```bash
./scripts/run.sh --vllm http://localhost:8000/v1
# or
./scripts/run.sh --vllm=https://my-vllm-host.example.com/v1
```

Ports:

- API: `http://localhost:3333`
- vLLM (only with `--vllm`): `http://localhost:8000`

## API

Health check:

```bash
curl http://localhost:8001/health
```

Predict from file upload:

```bash
curl -X POST "http://localhost:8001/predict" -F "file=@/absolute/path/to/document.pdf"
```
