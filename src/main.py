from __future__ import annotations

import json
import logging
import os
from pathlib import Path
from tempfile import TemporaryDirectory
from fastapi import FastAPI, File, HTTPException, UploadFile
from paddleocr import PaddleOCRVL

logging.basicConfig(
    level=os.getenv("LOG_LEVEL", "INFO"),
    format="%(asctime)s %(levelname)s [ocr-api] %(message)s",
)
logger = logging.getLogger(__name__)

app = FastAPI(title="OCR API", version="0.1.0")

use_vllm = os.getenv("USE_VLLM", "0") == "1"

paddleocr_kwargs = {
    "vl_rec_model_name": "PaddleOCR-VL-1.5-0.9B",
    "layout_detection_model_name": "PP-DocLayoutV3",
    "layout_detection_model_dir": "./models/PP-DocLayoutV3/",
}

if use_vllm:
    paddleocr_kwargs.update(
        {
            "vl_rec_backend": "vllm-server",
            "vl_rec_server_url": "http://localhost:8000/v1",
        }
    )
else:
    paddleocr_kwargs.update(
        {
            "vl_rec_model_dir": "./models/PaddleOCR-VL-1.5",
        }
    )

pipeline = PaddleOCRVL(**paddleocr_kwargs)

if use_vllm:
    logger.info("PaddleOCR initialized with vLLM backend at http://localhost:8000/v1")
else:
    logger.info("PaddleOCR initialized with local backend model_dir=./models/PaddleOCR-VL-1.5")

@app.get("/health")
def health() -> dict[str, str]:
    return {"status": "ok"}


@app.post("/predict")
async def predict(file: UploadFile = File(...)):
    logger.info("Received /predict request (filename=%s)", file.filename)
    results = []

    with TemporaryDirectory(dir="tmp", delete=True) as tmp_dir:
        tmp_path = Path(tmp_dir)
        input_path = tmp_path / file.filename
        input_path.write_bytes(await file.read())

        try:
            output = pipeline.predict(str(input_path))

        except Exception as exc:
            logger.exception("Prediction failed for filename=%s", file.filename)
            raise HTTPException(status_code=500, detail=f"Prediction failed: {exc}") from exc

        for idx, res in enumerate(output):
            json_path = tmp_path / f"output_{idx}.json"
            markdown_path = tmp_path / f"output_{idx}.md"
            
            res.save_to_json(save_path=str(json_path))
            res.save_to_markdown(save_path=str(markdown_path))

            results.append(json.loads(json_path.read_text(encoding="utf-8")))
            
    return results