import cv2
import numpy as np

MODEL_PATH = "models/Facial_Expression_Recognition_MobileFaceNet_July_2022.onnx"

EXPRESSIONS = [
    "angry",
    "disgust",
    "fearful",
    "happy",
    "neutral",
    "sad",
    "surprised",
]

# Load models
net = cv2.dnn.readNetFromONNX(MODEL_PATH)

face_detector = cv2.CascadeClassifier(
    cv2.data.haarcascades + "haarcascade_frontalface_default.xml"
)

# Change this to an actual image path
IMAGE_PATH = "test_face.jpg"

image = cv2.imread(IMAGE_PATH)

if image is None:
    raise FileNotFoundError(f"Could not load image: {IMAGE_PATH}")

gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)

faces = face_detector.detectMultiScale(
    gray,
    scaleFactor=1.1,
    minNeighbors=5,
    minSize=(80, 80),
)

if len(faces) == 0:
    print("❌ No face detected")
    exit()

# Use largest face
x, y, w, h = max(faces, key=lambda f: f[2] * f[3])

face = image[y:y+h, x:x+w]

# Resize to model input
face = cv2.resize(face, (112, 112))

# BGR -> RGB
face = cv2.cvtColor(face, cv2.COLOR_BGR2RGB)

# Normalize exactly as OpenCV Zoo implementation
face = face.astype(np.float32) / 255.0
face = (face - 0.5) / 0.5

# HWC -> NCHW
blob = cv2.dnn.blobFromImage(face)

# Inference
net.setInput(blob, "data")
output = net.forward("label")

print("\nRaw output:")
print("Shape:", output.shape)
print("Type:", output.dtype)
print("Values:", output)

# Handle the actual output shape
if output.ndim == 1:
    expression_index = int(np.argmax(output))
else:
    expression_index = int(np.argmax(output, axis=1)[0])

expression = EXPRESSIONS[expression_index]

print("\n==============================")
print("Facial Expression Analysis")
print("==============================")
print(f"Face detected : YES")
print(f"Face box      : ({x}, {y}, {w}, {h})")
print(f"Expression    : {expression}")
print(f"Class index   : {expression_index}")
print("==============================")