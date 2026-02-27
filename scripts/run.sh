#!/usr/bin/env bash

set -euo pipefail

log() {
    printf '[run.sh] %s\n' "$1"
}

export PADDLE_PDX_DISABLE_MODEL_SOURCE_CHECK=True
log "PADDLE_PDX_DISABLE_MODEL_SOURCE_CHECK=true"

use_vllm=0

for arg in "$@"; do
    if [[ "$arg" == "--vllm" ]]; then
        use_vllm=1
        break
    fi
done

if [[ "$use_vllm" -eq 1 ]]; then
    export USE_VLLM=1
    log "Mode: vLLM-enabled (USE_VLLM=1)"
    log "Starting vLLM server on http://localhost:8000 for model models/PaddleOCR-VL-1.5"
    
    vllm serve models/PaddleOCR-VL-1.5 \
        --served-model-name PaddleOCR-VL-1.5-0.9B \
        --trust-remote-code \
        --max-num-batched-tokens 16384 \
        --no-enable-prefix-caching \
        --mm-processor-cache-gb 0 &

    log "vLLM server started in background (pid=$!)"
else
    export USE_VLLM=0
    log "Mode: local OCR backend only (USE_VLLM=0)"
fi

.venv/bin/fastapi run src/main.py --port 8001