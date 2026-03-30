import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.decomposition import PCA
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score
import joblib
import os

print("Loading real SaYoPillow.csv data...")
df = pd.read_csv("SaYoPillow.csv")

# Rename columns to match what model_loader and the API expect
df = df.rename(columns={
    "sr": "Snoring Rate",
    "rr": "Respiration Rate",
    "t": "Body Temperature",
    "lm": "Limb Movement Rate",
    "bo": "Blood Oxygen Levels",
    "rem": "Eye Movement",
    "sr.1": "Sleep Hours",
    "hr": "Heart Rate",
    "sl": "Stress Level"
})

features = [
    "Snoring Rate",
    "Respiration Rate",
    "Body Temperature",
    "Limb Movement Rate",
    "Blood Oxygen Levels",
    "Eye Movement",
    "Sleep Hours",
    "Heart Rate"
]

X = df[features]
y = df["Stress Level"]

# Split
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

print("Scaling data...")
scaler = StandardScaler()
X_train_scaled = scaler.fit_transform(X_train)
X_test_scaled = scaler.transform(X_test)

print("Applying PCA (95% variance)...")
pca = PCA(n_components=0.95)
X_train_pca = pca.fit_transform(X_train_scaled)
X_test_pca = pca.transform(X_test_scaled)

print(f"PCA reduced 8 features to {pca.n_components_} components.")

print("Training Random Forest...")
rf = RandomForestClassifier(n_estimators=500, max_depth=10, random_state=42)
rf.fit(X_train_pca, y_train)

y_pred = rf.predict(X_test_pca)
acc = accuracy_score(y_test, y_pred)
print(f"Model trained! Accuracy on test set: {acc:.4f}")

# Save the models
joblib.dump(scaler, "scaler.pkl")
joblib.dump(pca, "pca.pkl")
joblib.dump(rf, "stress_model.pkl")
# Also overwrite the old random_forest_model.pkl just in case
joblib.dump(rf, "random_forest_model.pkl")

print("Saved new scaler.pkl, pca.pkl, and stress_model.pkl")
