from pathlib import Path
from math import hypot

import cv2
import mediapipe as mp
import numpy as np


_MODEL_PATH = (
    Path(__file__).resolve().parent
    / "models"
    / "face_landmarker.task"
)

BaseOptions = mp.tasks.BaseOptions
FaceLandmarker = mp.tasks.vision.FaceLandmarker
FaceLandmarkerOptions = mp.tasks.vision.FaceLandmarkerOptions
VisionRunningMode = mp.tasks.vision.RunningMode


_options = FaceLandmarkerOptions(
    base_options=BaseOptions(
        model_asset_path=str(_MODEL_PATH),
    ),
    running_mode=VisionRunningMode.IMAGE,
    num_faces=1,
    min_face_detection_confidence=0.5,
    min_face_presence_confidence=0.5,
    min_tracking_confidence=0.5,
)


_landmarker = FaceLandmarker.create_from_options(_options)


# MediaPipe Face Landmarker eye landmark indices
LEFT_EYE = [33, 160, 158, 133, 153, 144]
RIGHT_EYE = [362, 385, 387, 263, 373, 380]

# MediaPipe mouth landmark indices
MOUTH = [61, 291, 81, 178, 13, 14]


def _distance(a, b) -> float:
    return hypot(
        a.x - b.x,
        a.y - b.y,
    )


def _eye_aspect_ratio(landmarks, indices) -> float:
    """
    Calculate Eye Aspect Ratio (EAR).

    indices:
        p1, p2, p3, p4, p5, p6

    EAR = (|p2-p6| + |p3-p5|)
          ---------------------
                2|p1-p4|
    """

    p1, p2, p3, p4, p5, p6 = (
        landmarks[i]
        for i in indices
    )

    vertical_1 = _distance(p2, p6)
    vertical_2 = _distance(p3, p5)
    horizontal = _distance(p1, p4)

    if horizontal == 0:
        return 0.0

    return (vertical_1 + vertical_2) / (
        2.0 * horizontal
    )


def _mouth_aspect_ratio(landmarks) -> float:
    """
    Calculate a simple Mouth Aspect Ratio (MAR).

    Uses:
        61  - left corner
        291 - right corner
        81  - upper-left inner mouth
        178 - lower-left inner mouth
        13  - upper-center
        14  - lower-center
    """

    left = landmarks[61]
    right = landmarks[291]

    upper_left = landmarks[81]
    lower_left = landmarks[178]

    upper_center = landmarks[13]
    lower_center = landmarks[14]

    horizontal = _distance(left, right)

    if horizontal == 0:
        return 0.0

    vertical_1 = _distance(
        upper_left,
        lower_left,
    )

    vertical_2 = _distance(
        upper_center,
        lower_center,
    )

    return (vertical_1 + vertical_2) / (
        2.0 * horizontal
    )


def detect_landmarks(image_bytes: bytes) -> dict:
    """
    Detect facial landmarks and calculate
    eye and mouth geometry.
    """

    image_array = np.frombuffer(
        image_bytes,
        dtype=np.uint8,
    )

    image_bgr = cv2.imdecode(
        image_array,
        cv2.IMREAD_COLOR,
    )

    if image_bgr is None:
        raise ValueError("Could not decode image.")

    image_rgb = cv2.cvtColor(
        image_bgr,
        cv2.COLOR_BGR2RGB,
    )

    mp_image = mp.Image(
        image_format=mp.ImageFormat.SRGB,
        data=image_rgb,
    )

    result = _landmarker.detect(mp_image)

    if not result.face_landmarks:
        raise ValueError(
            "No facial landmarks detected."
        )

    landmarks = result.face_landmarks[0]

    left_ear = _eye_aspect_ratio(
        landmarks,
        LEFT_EYE,
    )

    right_ear = _eye_aspect_ratio(
        landmarks,
        RIGHT_EYE,
    )

    average_ear = (
        left_ear + right_ear
    ) / 2.0

    mar = _mouth_aspect_ratio(landmarks)

    return {
        "landmark_count": len(landmarks),

        "eye_analysis": {
            "left_ear": round(left_ear, 4),
            "right_ear": round(right_ear, 4),
            "average_ear": round(
                average_ear,
                4,
            ),
        },

        "mouth_analysis": {
            "mar": round(mar, 4),
        },

        "landmarks": [
            {
                "x": float(point.x),
                "y": float(point.y),
                "z": float(point.z),
            }
            for point in landmarks
        ],
    }