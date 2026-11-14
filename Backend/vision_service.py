from io import BytesIO
from pathlib import Path

import cv2
import numpy as np
from PIL import Image, UnidentifiedImageError


class FaceDetectionError(Exception):
    """Raised when an image cannot be processed or no face is detected."""


# OpenCV ships this pretrained face detector with its package.
_CASCADE_PATH = (
    cv2.data.haarcascades
    + "haarcascade_frontalface_default.xml"
)

# MobileFaceNet facial-expression model
_MODEL_PATH = (
    Path(__file__).resolve().parent
    / "models"
    / "Facial_Expression_Recognition_MobileFaceNet_July_2022.onnx"
)

# OpenCV Zoo expression classes
_EXPRESSIONS = [
    "angry",
    "disgust",
    "fearful",
    "happy",
    "neutral",
    "sad",
    "surprised",
]

# Load the CNN once when the module is imported.
_expression_model = cv2.dnn.readNetFromONNX(str(_MODEL_PATH))


def _predict_expression(face_bgr: np.ndarray) -> dict:
    """
    Run MobileFaceNet facial-expression recognition
    on a cropped face.
    """

    # MobileFaceNet expects 112 x 112 input.
    face = cv2.resize(face_bgr, (112, 112))

    # BGR -> RGB
    face = cv2.cvtColor(face, cv2.COLOR_BGR2RGB)

    # Convert to float and normalize:
    # [0, 255] -> [0, 1] -> [-1, 1]
    face = face.astype(np.float32) / 255.0
    face = (face - 0.5) / 0.5

    # HWC -> NCHW
    blob = cv2.dnn.blobFromImage(face)

    # Model input/output names
    _expression_model.setInput(blob, "data")
    output = _expression_model.forward("label")

    # Output shape: (1, 7)
    scores = output[0]

    expression_index = int(np.argmax(scores))

    return {
        "expression": _EXPRESSIONS[expression_index],
        "scores": {
            _EXPRESSIONS[i]: float(scores[i])
            for i in range(len(_EXPRESSIONS))
        },
    }


def analyze_face(image_bytes: bytes) -> dict:
    """
    Validate an uploaded image, detect a frontal face,
    and classify the detected face's facial expression.

    This function does NOT infer stress.
    """

    if not image_bytes:
        raise FaceDetectionError("The uploaded image is empty.")

    # Prevent unexpectedly large uploads from consuming excessive memory.
    max_bytes = 8 * 1024 * 1024

    if len(image_bytes) > max_bytes:
        raise FaceDetectionError("Image must be smaller than 8 MB.")

    try:
        with Image.open(BytesIO(image_bytes)) as image:
            image = image.convert("RGB")
            image.thumbnail((1600, 1600))
            rgb_image = np.asarray(image)

    except (UnidentifiedImageError, OSError, ValueError):
        raise FaceDetectionError(
            "Invalid image. Please upload a valid JPEG, PNG, or supported image."
        ) from None

    # Convert RGB -> grayscale for Haar cascade detection.
    gray = cv2.cvtColor(rgb_image, cv2.COLOR_RGB2GRAY)

    detector = cv2.CascadeClassifier(_CASCADE_PATH)

    if detector.empty():
        raise RuntimeError(
            "Could not load OpenCV's face detector."
        )

    faces = detector.detectMultiScale(
        gray,
        scaleFactor=1.1,
        minNeighbors=5,
        minSize=(60, 60),
    )

    if len(faces) == 0:
        raise FaceDetectionError(
            "No frontal face detected. Try a clear, well-lit image facing the camera."
        )

    # Select the largest detected face.
    x, y, width, height = max(
        faces,
        key=lambda face: int(face[2]) * int(face[3]),
    )

    # Extract the face from the RGB image.
    face_rgb = rgb_image[
        y:y + height,
        x:x + width
    ]

    # MobileFaceNet preprocessing expects BGR before RGB conversion.
    face_bgr = cv2.cvtColor(face_rgb, cv2.COLOR_RGB2BGR)

    # Run facial-expression recognition.
    expression_result = _predict_expression(face_bgr)

    return {
        "face_detected": True,
        "image_width": int(rgb_image.shape[1]),
        "image_height": int(rgb_image.shape[0]),
        "face_box": {
            "x": int(x),
            "y": int(y),
            "width": int(width),
            "height": int(height),
        },
        "facial_expression": expression_result["expression"],
        "expression_scores": expression_result["scores"],
        "analysis_status": "facial_expression_analysis",
        "message": (
            "Face detected and facial expression classified. "
            "This expression is not itself a stress diagnosis."
        ),
    }