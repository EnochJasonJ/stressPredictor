import time
from collections import deque

from live_vision_service import analyze_frame


class TemporalVisionAnalyzer:

    def __init__(self, window_seconds: float = 10.0):

        self.window_seconds = window_seconds
        self.samples = deque()

    # ========================================================
    # ADD FRAME
    # ========================================================

    def add_frame(self, image_bytes: bytes) -> dict:

        result = analyze_frame(image_bytes)

        now = time.time()

        self.samples.append({
            "timestamp": now,

            "face_detected":
                result["face_detected"],

            "ear":
                result["ear"],

            "eyes_closed":
                result["eyes_closed"],

            "expression":
                result["expression"],

            "expression_confidence":
                result["expression_confidence"],
        })

        self._cleanup(now)

        return self._build_summary()

    # ========================================================
    # REMOVE OLD FRAMES
    # ========================================================

    def _cleanup(self, now: float):

        cutoff = (
            now - self.window_seconds
        )

        while (
            self.samples
            and self.samples[0]["timestamp"]
                < cutoff
        ):

            self.samples.popleft()

    # ========================================================
    # BUILD SUMMARY
    # ========================================================

    def _build_summary(self) -> dict:

        valid_samples = [
            sample
            for sample in self.samples
            if sample["face_detected"]
            and sample["ear"] is not None
        ]

        if not valid_samples:

            return {
                "face_detected": False,

                "frames_analyzed": 0,

                "window_seconds":
                    self.window_seconds,

                "average_ear": None,

                "closed_eye_ratio": None,

                "longest_eye_closure": None,

                "fatigue_indicator": "none",

                "dominant_expression": None,

                "expression_stability": None,
            }

        # ====================================================
        # EYE METRICS
        # ====================================================

        ears = [
            sample["ear"]
            for sample in valid_samples
        ]

        closed_ratio = (
            sum(
                sample["eyes_closed"]
                for sample in valid_samples
            )
            / len(valid_samples)
        )

        average_ear = (
            sum(ears)
            / len(ears)
        )

        longest_closure = (
            self._longest_closure()
        )

        # ====================================================
        # FATIGUE INDICATOR
        # ====================================================

        if longest_closure >= 2.0:

            fatigue_indicator = (
                "possible_prolonged_eye_closure"
            )

        elif closed_ratio >= 0.3:

            fatigue_indicator = (
                "frequent_eye_closure"
            )

        else:

            fatigue_indicator = "none"

        # ====================================================
        # EXPRESSION
        # ====================================================

        expressions = [
            sample["expression"]
            for sample in valid_samples
            if sample["expression"] is not None
        ]

        if expressions:

            expression_counts = {}

            for expression in expressions:

                expression_counts[
                    expression
                ] = (
                    expression_counts.get(
                        expression,
                        0
                    ) + 1
                )

            dominant_expression = max(
                expression_counts,
                key=expression_counts.get
            )

            expression_stability = (
                expression_counts[
                    dominant_expression
                ]
                / len(expressions)
            )

        else:

            dominant_expression = None
            expression_stability = None

        # ====================================================
        # RESULT
        # ====================================================

        return {

            "face_detected": True,

            "frames_analyzed":
                len(valid_samples),

            "window_seconds":
                round(
                    self.window_seconds,
                    2
                ),

            "average_ear":
                round(
                    average_ear,
                    4
                ),

            "closed_eye_ratio":
                round(
                    closed_ratio,
                    4
                ),

            "longest_eye_closure":
                round(
                    longest_closure,
                    2
                ),

            "fatigue_indicator":
                fatigue_indicator,

            "dominant_expression":
                dominant_expression,

            "expression_stability":
                round(
                    expression_stability,
                    4
                )
                if expression_stability is not None
                else None,
        }

    # ========================================================
    # LONGEST EYE CLOSURE
    # ========================================================

    def _longest_closure(self) -> float:

        longest = 0.0

        closure_start = None

        for sample in self.samples:

            if (
                sample["face_detected"]
                and sample["eyes_closed"]
            ):

                if closure_start is None:

                    closure_start = (
                        sample["timestamp"]
                    )

            else:

                if closure_start is not None:

                    duration = (
                        sample["timestamp"]
                        - closure_start
                    )

                    longest = max(
                        longest,
                        duration
                    )

                    closure_start = None

        # Handle closure continuing
        # until the latest frame

        if closure_start is not None:

            duration = (
                self.samples[-1]["timestamp"]
                - closure_start
            )

            longest = max(
                longest,
                duration
            )

        return longest