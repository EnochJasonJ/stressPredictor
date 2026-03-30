# Stress Predictor – Backend

FastAPI backend that serves predictions from the trained Random Forest stress model.

## Setup

```bash
cd /Volumes/Enoch/projects/MlApp/backend

# Create and activate virtual environment (recommended)
python3 -m venv .venv
source .venv/bin/activate

# Install dependencies
pip install -r requirements.txt
```

## Run

```bash
python3 -m uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

The API will be available at: **http://localhost:8000**  
Interactive docs: **http://localhost:8000/docs**

## Endpoints

### `GET /health`
Returns `{"status": "ok"}` if the server is running.

### `POST /predict`
**Request body:**
```json
{
  "snoring_rate": 50.0,
  "respiration_rate": 18.0,
  "body_temperature": 98.6,
  "limb_movement_rate": 10.0,
  "blood_oxygen": 95.0,
  "eye_movement": 80.0,
  "sleep_hours": 7.0,
  "heart_rate": 72.0
}
```

**Response:**
```json
{
  "stress_level": 2,
  "stress_label": "Medium"
}
```

| `stress_level` | `stress_label` |
|---------------|----------------|
| 0             | Very Low       |
| 1             | Low            |
| 2             | Medium         |
| 3             | High           |
| 4             | Very High      |

## Flutter Integration

- **Android Emulator** → backend URL is `http://10.0.2.2:8000`
- **Physical Device** → replace with your machine's local IP, e.g. `http://192.168.1.x:8000`

Update the URL constant in `lib/services/api_service.dart`.

## Model

`stress_model.pkl` is the trained Random Forest classifier.  
- Input: 8 physiological signals  
- Preprocessing: Exact cloned `StandardScaler` and `PCA` (7 components) objects from the training Python notebook (`proces.ipynb`).  
- Output Mapping: Evaluates synthetic dataset class (0=Stressed, 4=Healthy), which is then mathematically inverted (e.g. 0=Healthy, 4=Stressed) before returning to standardise UI integration.
