import cv2
import requests
import time


API_URL = "http://127.0.0.1:8000/analyze-frame-temporal"

cap = cv2.VideoCapture(0)

if not cap.isOpened():
    raise RuntimeError("Could not open laptop camera.")


print("Camera started.")
print("Press Q to quit.")


last_request = 0
request_interval = 0.2  # ~5 FPS


try:
    while True:

        ret, frame = cap.read()

        if not ret:
            print("Failed to read camera frame.")
            break

        # Show camera locally
        cv2.imshow("Stress Predictor - Live Camera", frame)

        now = time.time()

        # Send approximately 5 frames/sec
        if now - last_request >= request_interval:

            last_request = now

            success, encoded = cv2.imencode(
                ".jpg",
                frame,
            )

            if not success:
                continue

            try:
                response = requests.post(
                    API_URL,
                    files={
                        "image": (
                            "frame.jpg",
                            encoded.tobytes(),
                            "image/jpeg",
                        )
                    },
                    timeout=5,
                )

                if response.status_code == 200:

                    data = response.json()

                    print(
                        "\n"
                        "============================================================\n"
                        "LIVE FRAME ANALYSIS\n"
                        "============================================================\n"
                        f"Face detected       : {data.get('face_detected')}\n"
                        f"Frames analyzed     : {data.get('frames_analyzed')}\n"
                        f"Window              : {data.get('window_seconds')} sec\n"
                        "\n"
                        f"Average EAR         : {data.get('average_ear')}\n"
                        f"Closed eye ratio    : {data.get('closed_eye_ratio')}\n"
                        f"Longest eye closure : {data.get('longest_eye_closure')} sec\n"
                        f"Fatigue indicator   : {data.get('fatigue_indicator')}\n"
                        "\n"
                        f"Expression          : {data.get('dominant_expression')}\n"
                        f"Expression stability: {data.get('expression_stability')}\n"
                    )

                    print("=" * 60)

                else:
                    print(
                        f"\nAPI error: "
                        f"{response.status_code} "
                        f"{response.text}"
                    )

            except requests.RequestException as exc:
                print(f"\nRequest failed: {exc}")

        if cv2.waitKey(1) & 0xFF == ord("q"):
            break

finally:
    cap.release()
    cv2.destroyAllWindows()
    print("\nCamera stopped.")