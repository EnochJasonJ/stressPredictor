"""
Stress Predictor – FastAPI Backend
===================================
POST /predict accepts 8 health features.
The model was trained on a synthetic dataset (processed by StandardScaler and PCA),
so the exact normalisation ranges are loaded from scaler.pkl and pca.pkl.

Run with:
    python3 -m uvicorn main:app --host 0.0.0.0 --port 8000 --reload
"""

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
import model_loader

app = FastAPI(
    title="Stress Predictor API",
    description="AI-powered stress level prediction from physiological signals.",
    version="1.0.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

STRESS_LABELS = {
    0: "Very Low",
    1: "Low",
    2: "Medium",
    3: "High",
    4: "Very High",
}

# ---------------------------------------------------------------------------
# Schemas
# ---------------------------------------------------------------------------

class PredictRequest(BaseModel):
    snoring_rate: float       = Field(...,  ge=0,   le=100)
    respiration_rate: float   = Field(...,  ge=0,   le=60)
    body_temperature: float   = Field(...,  ge=84,  le=110)
    limb_movement_rate: float = Field(...,  ge=0,   le=100)
    blood_oxygen: float       = Field(...,  ge=80,  le=100)
    eye_movement: float       = Field(...,  ge=0,   le=100)
    sleep_hours: float        = Field(...,  ge=0,   le=24)
    heart_rate: float         = Field(...,  ge=30,  le=220)


class PredictResponse(BaseModel):
    stress_level: int
    stress_label: str

# ---------------------------------------------------------------------------
# Routes
# ---------------------------------------------------------------------------

@app.get("/health", summary="Health check")
def health_check():
    return {"status": "ok", "message": "Stress Predictor API is running"}


@app.post("/predict", response_model=PredictResponse)
def predict_stress(request: PredictRequest) -> PredictResponse:
    """Predict stress level (0 = Very Low … 4 = Very High)."""
    # Use the 8 raw features (the model loader handles scaler -> pca -> predict)
    raw_features = [
        request.snoring_rate,
        request.respiration_rate,
        request.body_temperature,
        request.limb_movement_rate,
        request.blood_oxygen,
        request.eye_movement,
        request.sleep_hours,
        request.heart_rate,
    ]

    try:
        level = model_loader.predict(raw_features)
    except FileNotFoundError as exc:
        raise HTTPException(status_code=503, detail=str(exc))
    except Exception as exc:
        raise HTTPException(status_code=500, detail=f"Prediction failed: {exc}")

    return PredictResponse(
        stress_level=level,
        stress_label=STRESS_LABELS.get(level, "Unknown"),
    )
