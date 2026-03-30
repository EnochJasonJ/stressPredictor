import joblib
import os
import pandas as pd

# Path to the model and transformers
_MODEL_PATH = os.path.join(os.path.dirname(__file__), "stress_model.pkl")
_SCALER_PATH = os.path.join(os.path.dirname(__file__), "scaler.pkl")
_PCA_PATH = os.path.join(os.path.dirname(__file__), "pca.pkl")

# Singleton instance for our model and pipelines
_model = None
_scaler = None
_pca = None

# Exact column names used during training
_FEATURE_COLUMNS = [
    "Snoring Rate",
    "Respiration Rate",
    "Body Temperature",
    "Limb Movement Rate",
    "Blood Oxygen Levels",
    "Eye Movement",
    "Sleep Hours",
    "Heart Rate"
]

def _load_model():
    global _model, _scaler, _pca
    if not os.path.exists(_MODEL_PATH):
        raise FileNotFoundError(f"Model file not found at: {_MODEL_PATH}")
    if not os.path.exists(_SCALER_PATH):
        raise FileNotFoundError(f"Scaler file not found at: {_SCALER_PATH}")
    if not os.path.exists(_PCA_PATH):
        raise FileNotFoundError(f"PCA file not found at: {_PCA_PATH}")
    
    # Load all models
    print(f"[ModelLoader] Loading model & pipeline from {os.path.dirname(__file__)}...")
    _model = joblib.load(_MODEL_PATH)
    _scaler = joblib.load(_SCALER_PATH)
    _pca = joblib.load(_PCA_PATH)
    print("[ModelLoader] Model and pipeline loaded successfully.")

def predict(features: list[float]) -> int:
    """
    Predict stress level from 8 raw features.
    Applies the exact StandardScaler and PCA used during training before prediction.
    """
    global _model, _scaler, _pca
    if _model is None or _scaler is None or _pca is None:
        _load_model()
    
    # Needs to be a DataFrame to avoid scaler warnings about missing feature names
    X_raw = pd.DataFrame([features], columns=_FEATURE_COLUMNS)
    
    # 1. Scale
    X_scaled = _scaler.transform(X_raw)
    
    # 2. PCA transform (reduces to 7 components)
    X_pca = _pca.transform(X_scaled)
    
    # 3. Predict
    # Predict
    raw_prediction = int(_model.predict(X_pca)[0])
    
    # The model is trained on SaYoPillow.csv where:
    # 0 = Very Low (Healthy) -> 4 = Very High Stress
    return raw_prediction
