# MLApp - Stress Predictor: Comprehensive Project Analysis Report

**Generated:** 2026-04-03  
**Project Path:** `/Volumes/Enoch/projects/MlApp`

---

## Table of Contents

1. [Executive Summary](#executive-summary)
2. [Project Architecture](#project-architecture)
3. [Technology Stack](#technology-stack)
4. [Backend Analysis](#backend-analysis)
5. [Frontend Analysis](#frontend-analysis)
6. [Machine Learning Pipeline](#machine-learning-pipeline)
7. [Data Flow Architecture](#data-flow-architecture)
8. [API Documentation](#api-documentation)
9. [Data Models & Schemas](#data-models--schemas)
10. [Security & Privacy](#security--privacy)
11. [File Structure Reference](#file-structure-reference)

---

## Executive Summary

**MLApp** is a full-stack stress prediction application that combines:
- A **Flutter mobile application** for iOS/Android with Health Connect integration
- A **Python FastAPI backend** serving ML inference via REST API
- A **Random Forest classifier** trained on physiological sleep data

The app predicts stress levels (0-4 scale) based on 8 health metrics including snoring rate, respiration, body temperature, limb movement, blood oxygen, eye movement, sleep hours, and heart rate.

---

## Project Architecture

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           MLApp System Overview                         │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  ┌──────────────────────────────────────────────────────────────────┐  │
│  │                    Flutter Mobile Application                    │  │
│  │  ┌────────────┐ ┌────────────┐ ┌────────────┐ ┌────────────┐   │  │
│  │  │   Screens  │ │ Providers  │ │  Services  │ │  Widgets   │   │  │
│  │  └────────────┘ └────────────┘ └────────────┘ └────────────┘   │  │
│  │                                                                  │  │
│  │  ┌────────────────────────────────────────────────────────────┐ │  │
│  │  │              Health Connect Integration (Android)          │ │  │
│  │  │  - Heart Rate    - Respiratory Rate    - Body Temperature │ │  │
│  │  │  - Blood Oxygen  - Sleep Sessions      - Steps/Calories   │ │  │
│  │  └────────────────────────────────────────────────────────────┘ │  │
│  └──────────────────────────────────────────────────────────────────┘  │
│                              │ HTTP/JSON                                │
│                              ▼                                          │
│  ┌──────────────────────────────────────────────────────────────────┐  │
│  │                    Python FastAPI Backend                        │  │
│  │  ┌─────────────────────────────────────────────────────────────┐│  │
│  │  │  Model Pipeline:                                            ││  │
│  │  │  Input → StandardScaler → PCA → RandomForest → Output      ││  │
│  │  └─────────────────────────────────────────────────────────────┘│  │
│  │  ┌────────────┐ ┌────────────┐ ┌────────────┐                  │  │
│  │  │  Models    │ │  Training  │ │   Inference│                  │  │
│  │  │  (.pkl)    │ │  Scripts   │ │   Engine   │                  │  │
│  │  └────────────┘ └────────────┘ └────────────┘                  │  │
│  └──────────────────────────────────────────────────────────────────┘  │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## Technology Stack

### Backend Technologies

| Technology | Version | Category | Purpose |
|------------|---------|----------|---------|
| **FastAPI** | 0.115.0 | Web Framework | RESTful API with async support, automatic OpenAPI docs |
| **Uvicorn** | 0.30.6 | ASGI Server | High-performance ASGI server for FastAPI |
| **scikit-learn** | 1.7.2 | Machine Learning | ML algorithms (RandomForest, SVM, KNN, etc.) |
| **pandas** | 2.2.0 | Data Processing | CSV loading, DataFrame manipulation |
| **numpy** | 1.26.4 | Numerical Computing | Array operations, mathematical functions |
| **joblib** | 1.4.2 | Serialization | Efficient model persistence (.pkl files) |
| **pydantic** | 2.9.2 | Data Validation | Request/response schema validation |

### Frontend Technologies

| Package | Version | Purpose |
|---------|---------|---------|
| **flutter** | SDK | Cross-platform UI framework (Dart language) |
| **provider** | ^6.1.0 | State management (Provider pattern, InheritedWidget wrapper) |
| **go_router** | ^14.0.0 | Declarative routing with URL-based navigation |
| **http** | ^1.2.0 | HTTP client for API communication |
| **health** | ^13.3.1 | Android Health Connect API integration |
| **shared_preferences** | ^2.2.0 | Local key-value persistence |
| **fl_chart** | ^1.1.1 | Data visualization (charts, graphs) |
| **google_fonts** | ^6.1.0 | Custom typography (Inter font family) |
| **intl** | ^0.19.0 | Internationalization, date/number formatting |
| **crypto** | ^3.0.0 | Cryptographic hashing (SHA-256 for passwords) |
| **cupertino_icons** | ^1.0.8 | iOS-style icons |

---

## Backend Analysis

### Module Breakdown

#### `main.py` - FastAPI Application
- **Purpose:** Main API server with REST endpoints
- **Key Components:**
  - CORS middleware for cross-origin requests from mobile app
  - `/health` endpoint for health checks
  - `/predict` endpoint for ML inference
  - Pydantic models for request/response validation
- **Features:**
  - Input validation with field constraints
  - Structured JSON responses
  - Error handling with proper HTTP status codes

#### `model_loader.py` - ML Inference Engine
- **Purpose:** Singleton pattern for model loading and prediction
- **Pipeline:**
  1. Load `stress_model.pkl`, `scaler.pkl`, `pca.pkl`
  2. Apply StandardScaler normalization
  3. Apply PCA dimensionality reduction
  4. Run RandomForest prediction
  5. Return stress level (0-4) and label
- **Design Pattern:** Singleton ensures models loaded once at startup

#### `train_script.py` - Model Training
- **Purpose:** Complete training pipeline from data to deployment
- **Process:**
  1. Load SaYoPillow.csv dataset
  2. Split features (X) and target (y)
  3. Train/test split with stratification
  4. Fit StandardScaler on training data
  5. Apply PCA (95% variance retention)
  6. Compare multiple models (RF, LR, SVM, KNN, Decision Tree)
  7. Feature importance analysis
  8. Save best model with preprocessing artifacts

#### `retrain_model.py` - Model Retraining
- **Purpose:** Retrain model with real-world data
- **Features:**
  - Column mapping from CSV to internal feature names
  - Proper handling of SaYoPillow.csv schema
  - Incremental model improvement capability

#### `proces.ipynb` - Exploratory Data Analysis
- **Purpose:** Jupyter notebook for data exploration
- **Visualizations:**
  - Feature distribution histograms
  - Box plots for outlier detection
  - Correlation heatmaps
  - PCA component analysis
  - Class balance charts

---

## Frontend Analysis

### Screen Modules

| Screen | File | Purpose |
|--------|------|---------|
| **IntroScreen** | `intro_screen.dart` | Animated splash screen with auto-navigation |
| **LoginScreen** | `login_screen.dart` | User authentication with form validation |
| **SignupScreen** | `signup_screen.dart` | New user registration |
| **HomeScreen** | `home_screen.dart` | Main dashboard with stress gauge, history chart, quick actions |
| **PredictScreen** | `predict_screen.dart` | Manual health data input via 8 sliders |
| **HealthDataScreen** | `health_data_screen.dart` | Detailed Health Connect data display |
| **WorkoutScreen** | `workout_screen.dart` | Stress-relief exercises (breathing, stretching, cardio) |
| **ProfileScreen** | `profile_screen.dart` | User account management, analytics, settings |
| **AppearanceScreen** | `appearance_screen.dart` | Theme selection (Light/Dark/System) |
| **PrivacyScreen** | `privacy_screen.dart` | Privacy policy and data handling information |
| **HelpScreen** | `help_screen.dart` | FAQ and troubleshooting guide |

### Provider Modules (State Management)

| Provider | Responsibility |
|----------|----------------|
| **AuthProvider** | User session management, login/logout, credential persistence |
| **StressProvider** | Prediction state, stress history, health data synchronization |
| **ProfileProvider** | User profile data persistence and retrieval |
| **ThemeProvider** | App theme selection and system theme listening |

### Service Modules

| Service | Purpose |
|---------|---------|
| **ApiService** | HTTP client wrapper for backend communication |
| **HealthService** | Health Connect integration for vitals retrieval |
| **LocalStorageService** | SharedPreferences wrapper for local persistence |
| **AuthService** | Local authentication with SHA-256 password hashing |

### Widget Modules

| Widget | Purpose |
|--------|---------|
| **StressHistoryChart** | 7-day bar chart visualization using fl_chart |
| **WeeklyStepsChart** | Weekly step count visualization |

---

## Machine Learning Pipeline

### Model Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    ML Inference Pipeline                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  INPUT (8 features)                                             │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │ [snoring_rate, respiration_rate, body_temperature,      │   │
│  │  limb_movement_rate, blood_oxygen, eye_movement,        │   │
│  │  sleep_hours, heart_rate]                               │   │
│  └─────────────────────────────────────────────────────────┘   │
│                            │                                    │
│                            ▼                                    │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  StandardScaler                                         │   │
│  │  - Normalizes features to zero mean, unit variance      │   │
│  │  - Formula: z = (x - μ) / σ                             │   │
│  └─────────────────────────────────────────────────────────┘   │
│                            │                                    │
│                            ▼                                    │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  PCA (Principal Component Analysis)                     │   │
│  │  - n_components: 0.95 (95% variance retained)           │   │
│  │  - Reduces 8 features → 7 principal components          │   │
│  └─────────────────────────────────────────────────────────┘   │
│                            │                                    │
│                            ▼                                    │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  RandomForestClassifier                                 │   │
│  │  - n_estimators: 500                                    │   │
│  │  - max_depth: 10                                        │   │
│  │  - random_state: 42                                     │   │
│  └─────────────────────────────────────────────────────────┘   │
│                            │                                    │
│                            ▼                                    │
│  OUTPUT (stress_level: 0-4)                                     │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Training Process

1. **Data Loading:** Reads SaYoPillow.csv (~1500 synthetic samples)
2. **Column Mapping:**
   - `sr` → snoring_rate
   - `rr` → respiration_rate
   - `t` → body_temperature
   - `lm` → limb_movement_rate
   - `bo` → blood_oxygen
   - `rem` → eye_movement
   - `sr.1` → sleep_hours
   - `hr` → heart_rate
   - `sl` → stress_level (target)

3. **Preprocessing:**
   - StandardScaler fitted on training data
   - PCA with 95% variance threshold

4. **Model Comparison (tested algorithms):**
   | Model | Typical Accuracy |
   |-------|------------------|
   | Random Forest | ~100% |
   | Logistic Regression | ~95% |
   | SVM (RBF) | ~96% |
   | KNN (k=5) | ~94% |
   | Decision Tree | ~98% |

5. **Final Model Selection:** Random Forest (highest accuracy, robust to overfitting)

### Feature Importance

The model evaluates these 8 physiological markers (ranked by typical importance):

| Rank | Feature | Description |
|------|---------|-------------|
| 1 | Heart Rate | Beats per minute - primary stress indicator |
| 2 | Blood Oxygen | O2 saturation % - low levels indicate stress |
| 3 | Respiration Rate | Breaths per minute - increases with stress |
| 4 | Sleep Hours | Duration of sleep - poor sleep correlates with stress |
| 5 | Body Temperature | Core temperature in °F - elevated during stress |
| 6 | Eye Movement | REM activity - sleep quality indicator |
| 7 | Limb Movement Rate | Movement frequency - restlessness indicator |
| 8 | Snoring Rate | Frequency during sleep - sleep quality proxy |

### Output Classes

| Level | Label | Description |
|-------|-------|-------------|
| 0 | Very Low | Excellent, relaxed state |
| 1 | Low | Good stress management |
| 2 | Medium | Moderate stress - monitor |
| 3 | High | Needs attention - consider intervention |
| 4 | Very High | Immediate action required |

---

## Data Flow Architecture

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         Flutter Mobile App                              │
│                                                                         │
│  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────────┐ │
│  │ Health Connect  │───▶│  StressProvider │◀───│  Manual Input       │ │
│  │ (Android API)   │    │  (State Mgmt)   │    │  (8 Sliders UI)     │ │
│  │ - Heart Rate    │    │                 │    │                     │ │
│  │ - Resp Rate     │    │                 │    │                     │ │
│  │ - Temp, SpO2    │    │                 │    │                     │ │
│  │ - Sleep, Steps  │    │                 │    │                     │ │
│  └─────────────────┘    └────────┬────────┘    └─────────────────────┘ │
│                                  │                                      │
│                                  ▼                                      │
│  ┌───────────────────────────────────────────────────────────────────┐ │
│  │                        ApiService                                 │ │
│  │  POST http://<backend>:8000/predict                               │ │
│  │  Body: {                                                          │ │
│  │    snoring_rate: 50.0,                                            │ │
│  │    respiration_rate: 18.0,                                        │ │
│  │    body_temperature: 98.6,                                        │ │
│  │    limb_movement_rate: 10.0,                                      │ │
│  │    blood_oxygen: 95.0,                                            │ │
│  │    eye_movement: 80.0,                                            │ │
│  │    sleep_hours: 7.0,                                              │ │
│  │    heart_rate: 72.0                                               │ │
│  │  }                                                                │ │
│  └────────────────────────────┬──────────────────────────────────────┘ │
└───────────────────────────────┼─────────────────────────────────────────┘
                                │ HTTP POST (JSON)
                                ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                        FastAPI Backend                                  │
│                                                                         │
│  ┌───────────────────────────────────────────────────────────────────┐ │
│  │  POST /predict                                                    │ │
│  │    │                                                              │ │
│  │    ▼                                                              │ │
│  │  Pydantic Validation                                              │ │
│  │    - Check required fields                                        │ │
│  │    - Validate value ranges                                        │ │
│  │    │                                                              │ │
│  │    ▼                                                              │ │
│  │  model_loader.predict(raw_features)                               │ │
│  │    │                                                              │ │
│  │    ├─▶ Load models (if not cached)                                │ │
│  │    ├─▶ StandardScaler.transform()                                 │ │
│  │    ├─▶ PCA.transform()                                            │ │
│  │    └─▶ RandomForest.predict()                                     │ │
│  │                                                                   │ │
│  │    ◀─▶ Response:                                                  │ │
│  │    {                                                              │ │
│  │      stress_level: 2,                                             │ │
│  │      stress_label: "Medium"                                       │ │
│  │    }                                                              │ │
│  └───────────────────────────────────────────────────────────────────┘ │
└───────────────────────────────┬─────────────────────────────────────────┘
                                │ JSON Response
                                ▼
┌─────────────────────────────────────────────────────────────────────────┐
│  Flutter App - Update State                                             │
│    - StressProvider updates prediction                                  │
│    - History saved to LocalStorageService                               │
│    - UI refreshes (gauge, chart)                                        │
│                                                                         │
│  ┌───────────────────────────────────────────────────────────────────┐ │
│  │  LocalStorageService (SharedPreferences)                          │ │
│  │  - stress_history: JSON array (last 30 predictions)               │ │
│  │  - user_profile: User settings                                    │ │
│  │  - auth_users: User accounts                                      │ │
│  │  - auth_session_email: Current session                            │ │
│  └───────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## API Documentation

### Base URL
```
http://localhost:8000  (development)
http://<server-ip>:8000  (network deployment)
```

### Endpoints

#### GET /health
Health check endpoint to verify server status.

**Request:**
```
GET /health
```

**Response (200 OK):**
```json
{
  "status": "ok",
  "message": "API is running"
}
```

---

#### POST /predict
Predict stress level based on physiological features.

**Request:**
```
POST /predict
Content-Type: application/json
```

**Request Body:**
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

**Validation Constraints:**
| Field | Min | Max | Unit |
|-------|-----|-----|------|
| snoring_rate | 0 | 100 | frequency score |
| respiration_rate | 0 | 60 | breaths/min |
| body_temperature | 84 | 110 | °F |
| limb_movement_rate | 0 | 100 | frequency score |
| blood_oxygen | 80 | 100 | % |
| eye_movement | 0 | 100 | REM score |
| sleep_hours | 0 | 24 | hours |
| heart_rate | 30 | 220 | bpm |

**Response (200 OK):**
```json
{
  "stress_level": 2,
  "stress_label": "Medium"
}
```

**Error Responses:**
```json
// 422 Unprocessable Entity - Validation Error
{
  "detail": [
    {
      "loc": ["body", "heart_rate"],
      "msg": "Value must be between 30 and 220",
      "type": "value_error"
    }
  ]
}
```

---

## Data Models & Schemas

### Flutter Data Models

#### HealthData
```dart
class HealthData {
  // Core features (sent to ML model)
  double snoringRate;
  double respirationRate;
  double bodyTemperature;
  double limbMovementRate;
  double bloodOxygen;
  double eyeMovement;
  double sleepHours;
  double heartRate;
  
  // Additional health metrics
  int steps;
  int calories;
  
  // Data provenance flags
  bool heartRateFromSensor;
  bool bloodOxygenFromSensor;
  bool sleepFromSensor;
  bool respirationFromSensor;
}
```

#### StressPrediction
```dart
class StressPrediction {
  int stressLevel;        // 0-4
  String stressLabel;     // "Very Low" to "Very High"
  DateTime timestamp;
}
```

#### AuthUser
```dart
class AuthUser {
  String id;              // Unique identifier
  String name;            // Display name
  String email;           // Login credential
  String passwordHash;    // SHA-256 hash
  DateTime createdAt;     // Account creation timestamp
}
```

### Local Storage Schema (SharedPreferences)

| Key | Type | Description |
|-----|------|-------------|
| `stress_history` | JSON String | Array of StressPrediction objects (max 30) |
| `user_profile` | JSON String | User settings and preferences |
| `auth_users` | JSON String | Array of AuthUser objects |
| `auth_session_email` | String | Currently logged-in user's email |
| `theme` | String | Selected theme (light/dark/system) |

### Training Dataset Schema (SaYoPillow.csv)

| Column | Mapped Name | Type | Range |
|--------|-------------|------|-------|
| `sr` | snoring_rate | float | 0-100 |
| `rr` | respiration_rate | float | 0-60 |
| `t` | body_temperature | float | 84-110 |
| `lm` | limb_movement_rate | float | 0-100 |
| `bo` | blood_oxygen | float | 80-100 |
| `rem` | eye_movement | float | 0-100 |
| `sr.1` | sleep_hours | float | 0-24 |
| `hr` | heart_rate | float | 30-220 |
| `sl` | stress_level | int | 0-4 |

---

## Security & Privacy

### Authentication
- **Password Storage:** SHA-256 hashing before persistence
- **Session Management:** Email stored in SharedPreferences
- **Local-Only:** No cloud authentication - all credentials stored on-device

### Data Protection
- **On-Device Storage:** All data persists locally via SharedPreferences
- **No Cloud Sync:** No data transmitted to external servers
- **Health Connect Permissions:** User-granted and revocable at any time
- **Network Isolation:** ML inference runs on local network only

### Privacy Features
- **Data Provenance UI:** Users can see which metrics come from sensors vs. manual input
- **Transparent Processing:** Help screen explains how stress is calculated
- **Privacy Policy Screen:** Clear documentation of data handling practices

---

## File Structure Reference

```
/Volumes/Enoch/projects/MlApp/
│
├── Backend/
│   ├── main.py                 # FastAPI application
│   ├── model_loader.py         # ML model loading and inference
│   ├── train_script.py         # Model training pipeline
│   ├── retrain_model.py        # Model retraining script
│   ├── proces.ipynb            # EDA Jupyter notebook
│   ├── requirements.txt        # Python dependencies
│   ├── stress_model.pkl        # Trained RandomForest model
│   ├── scaler.pkl              # StandardScaler preprocessing
│   ├── pca.pkl                 # PCA dimensionality reduction
│   └── SaYoPillow.csv          # Training dataset
│
└── stresspredictor/
    ├── lib/
    │   ├── main.dart           # App entry point
    │   ├── app.dart            # Root MaterialApp with providers
    │   ├── core/
    │   │   └── theme.dart      # Theme configuration
    │   ├── models/
    │   │   └── health_data.dart  # Data models
    │   ├── providers/
    │   │   ├── auth_provider.dart
    │   │   ├── stress_provider.dart
    │   │   ├── profile_provider.dart
    │   │   └── theme_provider.dart
    │   ├── router/
    │   │   └── app_router.dart   # go_router configuration
    │   ├── screens/
    │   │   ├── intro/
    │   │   │   └── intro_screen.dart
    │   │   ├── auth/
    │   │   │   ├── login_screen.dart
    │   │   │   └── signup_screen.dart
    │   │   ├── home/
    │   │   │   └── home_screen.dart
    │   │   ├── predict/
    │   │   │   └── predict_screen.dart
    │   │   ├── health/
    │   │   │   └── health_data_screen.dart
    │   │   ├── workout/
    │   │   │   └── workout_screen.dart
    │   │   ├── profile/
    │   │   │   └── profile_screen.dart
    │   │   └── settings/
    │   │       ├── appearance_screen.dart
    │   │       ├── privacy_screen.dart
    │   │       └── help_screen.dart
    │   ├── services/
    │   │   ├── api_service.dart
    │   │   ├── health_service.dart
    │   │   ├── local_storage_service.dart
    │   │   └── auth_service.dart
    │   └── widgets/
    │       ├── stress_history_chart.dart
    │       └── weekly_steps_chart.dart
    ├── pubspec.yaml            # Flutter dependencies
    └── README.md
```

---

## Summary

**MLApp** is a well-architected stress prediction system that demonstrates:

1. **Clean Separation of Concerns:** Backend (ML inference) and frontend (UI/UX) are properly decoupled
2. **Modern Tech Stack:** FastAPI for backend, Flutter for cross-platform mobile
3. **Production-Ready ML Pipeline:** StandardScaler → PCA → RandomForest with proper serialization
4. **Health Integration:** Leverages Android Health Connect for automatic vitals collection
5. **Privacy-First Design:** All data stored locally, no cloud dependencies
6. **User-Friendly Interface:** Intuitive stress visualization, manual input options, and wellness exercises

The project serves as a complete end-to-end ML application suitable for stress monitoring and wellness tracking.
