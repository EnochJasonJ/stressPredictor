from pathlib import Path

from face_landmark_service import detect_landmarks
from term_image.image import from_file
import base64
import sys


def print_image_warp(image_path, width="auto", height="auto"):
    with open(image_path, "rb") as f:
        b64_data = base64.b64encode(f.read()).decode("ascii")

    # width/height accept character cells (e.g., "40"), pixels (e.g., "300px"), or percentages (e.g., "50%")
    osc = f"\033]1337;File=inline=1;width={width};height={height};preserveAspectRatio=1:{b64_data}\a\n"
    sys.stdout.write(osc)
    sys.stdout.flush()


image_path = Path("cry.jpeg")
img = from_file("cry.jpeg")

image_bytes = image_path.read_bytes()

result = detect_landmarks(image_bytes)

print("=" * 50)
print("FACE LANDMARK + EYE/MOUTH TEST for image: ", image_path)
print("=" * 50)
print("=" * 50)
print("Image")
print_image_warp("cry.jpeg", width="40")
print("=" * 50)

print(
    "Landmarks detected :",
    result["landmark_count"],
)

print("\n👁️ Eye Analysis")

eye = result["eye_analysis"]

print(
    f"  Left EAR     : {eye['left_ear']}"
)

print(
    f"  Right EAR    : {eye['right_ear']}"
)

print(
    f"  Average EAR  : {eye['average_ear']}"
)

print("\n👄 Mouth Analysis")

mouth = result["mouth_analysis"]

print(
    f"  MAR          : {mouth['mar']}"
)

print("=" * 50)