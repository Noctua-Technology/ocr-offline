#!/usr/bin/env bash

set -euo pipefail

log() {
    printf '[run.sh] %s\n' "$1"
}

export PADDLE_PDX_DISABLE_MODEL_SOURCE_CHECK=True

use_vllm=0
vllm_server_url="http://localhost:8000/v1"
start_local_vllm=0

while [[ $# -gt 0 ]]; do
    case "$1" in
        --vllm)
            use_vllm=1
            if [[ $# -gt 1 && "${2:0:2}" != "--" ]]; then
                vllm_server_url="$2"
                shift
            else
                start_local_vllm=1
            fi
            ;;
        --vllm=*)
            use_vllm=1
            vllm_server_url="${1#*=}"
            ;;
    esac
    shift
done

if [[ "$use_vllm" -eq 1 ]]; then
    export USE_VLLM=1
    export VLLM_SERVER_URL="$vllm_server_url"
    log "Mode: vLLM-enabled (USE_VLLM=1, VLLM_SERVER_URL=$VLLM_SERVER_URL)"

    if [[ "$start_local_vllm" -eq 1 ]]; then
        log "Starting vLLM server on http://localhost:8000 for model models/PaddleOCR-VL-1.5"

        vllm serve models/PaddleOCR-VL-1.5 \
            --served-model-name PaddleOCR-VL-1.5-0.9B \
            --trust-remote-code \
            --max-num-batched-tokens 16384 \
            --no-enable-prefix-caching \
            --mm-processor-cache-gb 0 &

        log "vLLM server started in background (pid=$!)"
    fi
else
    export USE_VLLM=0
    log "Mode: local OCR backend only (USE_VLLM=0)"
fi

.venv/bin/fastapi run src/main.py --port 3333