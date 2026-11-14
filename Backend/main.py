"""
Stress Predictor – FastAPI Backend
===================================
POST /predict accepts 8 health features.
The model was trained on a synthetic dataset (processed by StandardScaler and PCA),
so the exact normalisation ranges are loaded from scaler.pkl and pca.pkl.

Run with:
    python3 -m uvicorn main:app --host 0.0.0.0 --port 8000 --reload
"""

from fastapi import FastAPI, HTTPException, UploadFile, File, Form
from vision_service import analyze_face, FaceDetectionError
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


@app.post("/analyze-face", summary="Detect a face in an uploaded image")
async def analyze_face_endpoint(
    image: UploadFile = File(...),
):
    content_type = (image.content_type or "").lower()
    if content_type not in ("image/jpeg", "image/png", "image/webp"):
        raise HTTPException(
            status_code=415,
            detail="Upload a JPEG, PNG, or WebP image.",
        )

    try:
        image_bytes = await image.read()
        return analyze_face(image_bytes)
    except FaceDetectionError as exc:
        raise HTTPException(status_code=422, detail=str(exc)) from exc
    finally:
        await image.close()

def combine_stress_signals(
    physiological_level: int,
    facial_expression: str,
) -> int:
    """
    Combine physiological stress prediction with
    facial expression as contextual information.

    Physiological prediction remains the primary signal.
    """

    # Stress-related expressions
    stress_expressions = {
        "angry",
        "fearful",
        "sad",
    }

    # Positive/neutral expressions
    non_stress_expressions = {
        "happy",
        "neutral",
        "surprised",
        "disgust",
    }

    # Medium physiological stress + stress-related expression
    if physiological_level == 2 and facial_expression in stress_expressions:
        return 3

    # Low physiological stress + stress-related expression
    # increases the indication only slightly.
    if physiological_level == 1 and facial_expression in stress_expressions:
        return 2

    # Very low + stress expression
    if physiological_level == 0 and facial_expression in stress_expressions:
        return 1

    # Otherwise, trust the physiological model.
    return physiological_level


@app.post("/predict-multimodal")
async def predict_multimodal(
    image: UploadFile = File(...),

    snoring_rate: float = Form(..., ge=0, le=100),
    respiration_rate: float = Form(..., ge=0, le=60),
    body_temperature: float = Form(..., ge=84, le=110),
    limb_movement_rate: float = Form(..., ge=0, le=100),
    blood_oxygen: float = Form(..., ge=80, le=100),
    eye_movement: float = Form(..., ge=0, le=100),
    sleep_hours: float = Form(..., ge=0, le=24),
    heart_rate: float = Form(..., ge=30, le=220)
):
    """
    Combine physiological stress prediction
    with facial-expression analysis.
    """

    print("\n" + "=" * 60)
    print("📥 MULTIMODAL PREDICTION REQUEST")
    print("=" * 60)

    print("📊 Physiological values received:")
    print(f"  Snoring Rate       : {snoring_rate}")
    print(f"  Respiration Rate   : {respiration_rate}")
    print(f"  Body Temperature   : {body_temperature}")
    print(f"  Limb Movement Rate : {limb_movement_rate}")
    print(f"  Blood Oxygen       : {blood_oxygen}")
    print(f"  Eye Movement       : {eye_movement}")
    print(f"  Sleep Hours        : {sleep_hours}")
    print(f"  Heart Rate         : {heart_rate}")

    print("\n🖼️ Image:")
    print(f"  Filename           : {image.filename}")
    print(f"  Content Type       : {image.content_type}")

    content_type = (image.content_type or "").lower()

    if content_type not in ("image/jpeg", "image/png", "image/webp"):
        raise HTTPException(
            status_code=415,
            detail="Upload a JPEG, PNG, or WebP image.",
        )

    try:
        # -------------------------
        # 1. Physiological prediction
        # -------------------------

        raw_features = [
            snoring_rate,
            respiration_rate,
            body_temperature,
            limb_movement_rate,
            blood_oxygen,
            eye_movement,
            sleep_hours,
            heart_rate,
        ]

        physiological_level = model_loader.predict(raw_features)

        physiological_label = STRESS_LABELS.get(
            physiological_level,
            "Unknown",
        )

        # -------------------------
        # 2. Facial analysis
        # -------------------------

        image_bytes = await image.read()

        print(f"  Image Size         : {len(image_bytes)} bytes")

        face_result = analyze_face(image_bytes)

        facial_expression = face_result["facial_expression"]

        # -------------------------
        # 3. Fusion
        # -------------------------

        print(f"  Physiological Label : {physiological_label}")

        print("\n👤 Running facial expression analysis...")

        # your existing analyze_face(...) call

        print(f"  Facial Expression   : {facial_expression}")

        print("\n🔀 Running multimodal fusion...")

        final_level = combine_stress_signals(
            physiological_level,
            facial_expression,
        )

        final_label = STRESS_LABELS.get(
            final_level,
            "Unknown",
        )

        print(f"  Final Level         : {final_level}")
        print(f"  Final Label         : {final_label}")

        print("=" * 60 + "\n")
        # -------------------------
        # 4. Final response
        # -------------------------

        return {
            "physiological_stress": {
                "level": physiological_level,
                "label": physiological_label,
            },
            "facial_expression": facial_expression,
            "final_stress": {
                "level": final_level,
                "label": final_label,
            },
            "analysis_status": "multimodal_stress_analysis",
            "message": (
                "Stress indication generated using physiological "
                "signals and facial-expression context."
            ),
        }

    except FaceDetectionError as exc:
        raise HTTPException(
            status_code=422,
            detail=str(exc),
        ) from exc

    except FileNotFoundError as exc:
        raise HTTPException(
            status_code=503,
            detail=str(exc),
        ) from exc

    except Exception as exc:
        raise HTTPException(
            status_code=500,
            detail=f"Multimodal prediction failed: {exc}",
        ) from exc

    finally:
        await image.close()