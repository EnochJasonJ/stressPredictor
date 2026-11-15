import cv2
import mediapipe as mp
import numpy as np
from pathlib import Path


# ============================================================
# LANDMARK INDICES
# ============================================================

LEFT_EYE = [33, 160, 158, 133, 153, 144]
RIGHT_EYE = [362, 385, 387, 263, 373, 380]

MOUTH = [61, 291, 81, 178]


# ============================================================
# MODEL PATHS
# ============================================================

BASE_DIR = Path(__file__).resolve().parent

LANDMARK_MODEL_PATH = (
    BASE_DIR
    / "models"
    / "face_landmarker.task"
)

EXPRESSION_MODEL_PATH = (
    BASE_DIR
    / "models"
    / "Facial_Expression_Recognition_MobileFaceNet_July_2022.onnx"
)


# ============================================================
# MEDIAPIPE
# ============================================================

BaseOptions = mp.tasks.BaseOptions
VisionRunningMode = mp.tasks.vision.RunningMode
FaceLandmarker = mp.tasks.vision.FaceLandmarker
FaceLandmarkerOptions = mp.tasks.vision.FaceLandmarkerOptions


_options = FaceLandmarkerOptions(
    base_options=BaseOptions(
        model_asset_path=str(LANDMARK_MODEL_PATH)
    ),
    running_mode=VisionRunningMode.IMAGE,
    num_faces=1,
    min_face_detection_confidence=0.5,
    min_face_presence_confidence=0.5,
    min_tracking_confidence=0.5,
)

_face_landmarker = FaceLandmarker.create_from_options(
    _options
)


# ============================================================
# EXPRESSION MODEL
# ============================================================

_expression_model = cv2.dnn.readNetFromONNX(
    str(EXPRESSION_MODEL_PATH)
)

EXPRESSIONS = [
    "angry",
    "disgust",
    "fearful",
    "happy",
    "neutral",
    "sad",
    "surprised",
]


# ============================================================
# HELPERS
# ============================================================

def _distance(a, b):
    return np.linalg.norm(
        np.array(a) - np.array(b)
    )


def _eye_aspect_ratio(landmarks, indices):

    p1, p2, p3, p4, p5, p6 = [
        landmarks[i]
        for i in indices
    ]

    vertical_1 = _distance(p2, p6)
    vertical_2 = _distance(p3, p5)
    horizontal = _distance(p1, p4)

    return (
        vertical_1 + vertical_2
    ) / (2.0 * horizontal)


def _mouth_aspect_ratio(landmarks):

    left = landmarks[MOUTH[0]]
    right = landmarks[MOUTH[1]]
    top = landmarks[MOUTH[2]]
    bottom = landmarks[MOUTH[3]]

    horizontal = _distance(left, right)
    vertical = _distance(top, bottom)

    return vertical / horizontal


def _predict_expression(face_bgr):

    face = cv2.resize(
        face_bgr,
        (112, 112)
    )

    face = cv2.cvtColor(
        face,
        cv2.COLOR_BGR2RGB
    )

    face = face.astype(np.float32) / 255.0

    face = (
        face - 0.5
    ) / 0.5

    blob = cv2.dnn.blobFromImage(face)

    _expression_model.setInput(
        blob,
        "data"
    )

    output = _expression_model.forward(
        "label"
    )

    scores = output[0]

    expression_index = int(
        np.argmax(scores)
    )

    return {
        "expression": EXPRESSIONS[
            expression_index
        ],
        "confidence": float(
            np.max(scores)
        ),
    }


# ============================================================
# MAIN FRAME ANALYSIS
# ============================================================

def analyze_frame(image_bytes: bytes) -> dict:

    image = cv2.imdecode(
        np.frombuffer(
            image_bytes,
            np.uint8
        ),
        cv2.IMREAD_COLOR,
    )

    if image is None:
        raise ValueError(
            "Invalid image frame."
        )

    rgb = cv2.cvtColor(
        image,
        cv2.COLOR_BGR2RGB
    )

    mp_image = mp.Image(
        image_format=mp.ImageFormat.SRGB,
        data=rgb,
    )

    result = _face_landmarker.detect(
        mp_image
    )

    # --------------------------------------------------------
    # NO FACE
    # --------------------------------------------------------

    if not result.face_landmarks:

        return {
            "face_detected": False,
            "expression": None,
            "expression_confidence": None,
            "ear": None,
            "eyes_closed": False,
            "mar": None,
            "yawn_detected": False,
        }

    # --------------------------------------------------------
    # LANDMARKS
    # --------------------------------------------------------

    face = result.face_landmarks[0]

    h, w = image.shape[:2]

    landmarks = [
        (
            lm.x * w,
            lm.y * h
        )
        for lm in face
    ]

    # --------------------------------------------------------
    # EYE ANALYSIS
    # --------------------------------------------------------

    left_ear = _eye_aspect_ratio(
        landmarks,
        LEFT_EYE
    )

    right_ear = _eye_aspect_ratio(
        landmarks,
        RIGHT_EYE
    )

    ear = (
        left_ear + right_ear
    ) / 2.0

    eyes_closed = bool(
        ear < 0.10
    )

    # --------------------------------------------------------
    # MOUTH ANALYSIS
    # --------------------------------------------------------

    mar = _mouth_aspect_ratio(
        landmarks
    )

    # Keep this disabled for now.
    # Our current MAR calculation is not reliable enough
    # for yawn detection.

    yawn_detected = False

    # --------------------------------------------------------
    # EXPRESSION
    # --------------------------------------------------------

    x_coords = [
        point[0]
        for point in landmarks
    ]

    y_coords = [
        point[1]
        for point in landmarks
    ]

    x_min = max(
        0,
        int(min(x_coords))
    )

    x_max = min(
        w,
        int(max(x_coords))
    )

    y_min = max(
        0,
        int(min(y_coords))
    )

    y_max = min(
        h,
        int(max(y_coords))
    )

    face_bgr = image[
        y_min:y_max,
        x_min:x_max
    ]

    expression = None
    expression_confidence = None

    if face_bgr.size > 0:

        expression_result = (
            _predict_expression(
                face_bgr
            )
        )

        expression = (
            expression_result[
                "expression"
            ]
        )

        expression_confidence = (
            expression_result[
                "confidence"
            ]
        )

    # --------------------------------------------------------
    # RESULT
    # --------------------------------------------------------

    return {

        "face_detected": True,

        "expression": expression,

        "expression_confidence": round(
            expression_confidence,
            4
        )
        if expression_confidence is not None
        else None,

        "ear": round(
            float(ear),
            4
        ),

        "eyes_closed": eyes_closed,

        "mar": round(
            float(mar),
            4
        ),

        "yawn_detected": yawn_detected,
    }