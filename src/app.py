from fastapi import FastAPI, UploadFile, File, HTTPException, Query
from typing import Literal
from .main import ocr_service

app = FastAPI(title="Paddle OCR")

SupportedLangs = Literal["ar", "en", "fa", "fr", "de", "hi", "id", "ja", "ko", "zh", "pt", "ru", "es", "ur", "vi"]

@app.get("/")
async def root():
    return {"message": "OCR API is online and ready"}

@app.get("/health")
def health_check():
    return {
        "status": "ready",
        "models_loaded": list(ocr_service.models.keys()),
        "message": "OCR engine is ready"
    }
    

@app.post("/ocr/predict")
async def predict_text(
    file: UploadFile = File(...),
    lang: SupportedLangs = Query("en")
):
    try:
        file_bytes = await file.read()
        
        content_type = file.content_type
        # checks if the file has no content type
        if not content_type or content_type == "application/octet-stream":
            if file.filename.lower().endswith(".pdf"):
                content_type = "application/pdf"
            elif file.filename.lower().endswith((".jpg", ".jpeg")):
                content_type = "image/jpeg"
            else:
                content_type = "image/png"

        return ocr_service.run_ocr(file_bytes, content_type=content_type, lang=lang)

    except Exception as e:
        print(f"OCR Error: {repr(e)}")
        
        raise HTTPException(status_code=500, detail=f"OCR Error: {str(e)}")