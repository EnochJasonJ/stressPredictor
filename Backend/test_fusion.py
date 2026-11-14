from main import combine_stress_signals


tests = [
    (4, "happy"),
    (2, "sad"),
    (1, "sad"),
    (0, "sad"),
    (2, "happy"),
    (1, "happy"),
]

for physiological, expression in tests:
    final = combine_stress_signals(
        physiological,
        expression,
    )

    print(
        f"Physiological={physiological}, "
        f"Face={expression}, "
        f"Final={final}"
    )