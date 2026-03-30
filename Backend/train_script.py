import pandas as pd
df = pd.read_csv("SaYoPillow.csv")
display(df.head(5))
df = df.rename(columns={"sr":"Snoring Rate","rr": "Respiration rate","t":"Body Temperature","lm": "Limb Movement Rate","bo": "Blood Oxygen Levels","rem": "Eye movement","sr.1": "No. of hours of Sleep","hr": "Heart Rate","sl": "Stress Level"})
display(df.head(1))
display(df.isna().sum())
print()
display(df.info())
print()
display(df.duplicated().sum())
display(df["Stress Level"].value_counts())
display(df.describe())
import matplotlib.pyplot as plt
import seaborn as sns

df.hist(figsize=(12,8))
plt.show()
plt.figure(figsize=(12,6))
sns.boxplot(data=df)
plt.xticks(rotation=90)
plt.show()
plt.figure(figsize=(10,8))
sns.heatmap(df.corr(), annot=True, cmap='Purples')
plt.show()
X = df.drop("Stress Level",axis = 1)
y = df["Stress Level"]
!pip install scikit-learn
from sklearn.model_selection import train_test_split

X_train, X_test, y_train, y_test = train_test_split(X,y,test_size = 0.2, random_state = 42)
from sklearn.preprocessing import StandardScaler

scaler = StandardScaler()
X_train_scaled = scaler.fit_transform(X_train)
X_test_scaled = scaler.transform(X_test)
from sklearn.decomposition import PCA

pca = PCA(n_components=0.95)
X_train_pca = pca.fit_transform(X_train_scaled)
X_test_pca = pca.transform(X_test_scaled)

print("Number of components:", pca.n_components_)
import numpy as np 

plt.plot(np.cumsum(pca.explained_variance_ratio_))
plt.xlabel("Number of Components")
plt.ylabel("Cumulative Explained Variance")
plt.show()
from sklearn.linear_model import LogisticRegression

log_model = LogisticRegression(max_iter=1000)
log_model.fit(X_train_pca,y_train)
y_pred_log = log_model.predict(X_test_pca)
print("Logistic Regression Accuracy:",accuracy_score(y_test,y_pred_log))

train_acc = model.score(X_train_pca, y_train)
test_acc = model.score(X_test_pca, y_test)

print("Train Accuracy: ", train_acc)
print("Test Accuracy: ", test_acc)
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score

model = RandomForestClassifier()
model.fit(X_train_pca, y_train)
y_pred = model.predict(X_test_pca)
print("Accuracy: ",accuracy_score(y_test,y_pred))
train_acc = model.score(X_train_pca, y_train)
test_acc = model.score(X_test_pca, y_test)

print("Train Accuracy: ", train_acc)
print("Test Accuracy: ", test_acc)
import matplotlib.pyplot as plt

plt.scatter(X_train_pca[:,0],X_train_pca[:,1],c=y_train,cmap="viridis")
plt.xlabel("First Principal Component")
plt.ylabel("Second Principal Component")
plt.title("PCA Visualization of Stress Level")
plt.colorbar(label = "Stress Level")
plt.show()
from sklearn.datasets import make_classification
import pandas as pd

X, y = make_classification(
    n_samples=1500,
    n_features=8,
    n_informative=5,      # features actually affecting stress
    n_redundant=1,        # slightly correlated features
    n_classes=5,
    class_sep=2,        # controls difficulty
    random_state=42
)

columns = [
    "Snoring Rate",
    "Respiration Rate",
    "Body Temperature",
    "Limb Movement Rate",
    "Blood Oxygen Levels",
    "Eye Movement",
    "Sleep Hours",
    "Heart Rate"
]

df = pd.DataFrame(X, columns=columns)
df["Stress Level"] = y
df["Snoring Rate"] = df["Snoring Rate"]*10 + 70
df["Respiration Rate"] = df["Respiration Rate"]*3 + 20
df["Body Temperature"] = df["Body Temperature"]*1 + 37
df["Heart Rate"] = df["Heart Rate"]*10 + 70
df["Sleep Hours"] = df["Sleep Hours"]*2 + 6
X = df.drop("Stress Level", axis=1)
y = df["Stress Level"]
print("X:\n",X)
print()
print("y:\n",y)
from sklearn.model_selection import train_test_split

X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=42
)
from sklearn.preprocessing import StandardScaler

scaler = StandardScaler()

X_train_scaled = scaler.fit_transform(X_train)
X_test_scaled = scaler.transform(X_test)
from sklearn.decomposition import PCA

pca = PCA(n_components=0.95)

X_train_pca = pca.fit_transform(X_train_scaled)
X_test_pca = pca.transform(X_test_scaled)

print("Number of components:", pca.n_components_)
from sklearn.linear_model import LogisticRegression

log_model = LogisticRegression(max_iter=1000)
log_model.fit(X_train_pca, y_train)
from sklearn.ensemble import RandomForestClassifier

rf_model = RandomForestClassifier(n_estimators=500,max_depth=10,random_state=42)

rf_model.fit(X_train_pca, y_train)
y_pred = rf_model.predict(X_test_pca)
from sklearn.metrics import accuracy_score, classification_report

print("Accuracy:", accuracy_score(y_test, y_pred))
print(classification_report(y_test, y_pred))
import matplotlib.pyplot as plt
rf_model_raw = RandomForestClassifier(n_estimators=500, random_state=42)

rf_model_raw.fit(X_train_scaled, y_train)

importance = rf_model_raw.feature_importances_

feat_importance = pd.Series(importance, index=X.columns)

feat_importance.sort_values().plot(kind="barh")

plt.title("Feature Importance for Stress Prediction")
plt.show()
from sklearn.linear_model import LogisticRegression
from sklearn.ensemble import RandomForestClassifier
from sklearn.svm import SVC
from sklearn.neighbors import KNeighborsClassifier
from sklearn.tree import DecisionTreeClassifier
from sklearn.metrics import accuracy_score

models = {
    "Logistic Regression": LogisticRegression(max_iter=1000),
    "Random Forest": RandomForestClassifier(n_estimators=500, random_state=42),
    "SVM": SVC(),
    "KNN": KNeighborsClassifier(n_neighbors=5),
    "Decision Tree": DecisionTreeClassifier(random_state=42)
}

results = {}

for name, model in models.items():
    model.fit(X_train_pca, y_train)
    y_pred = model.predict(X_test_pca)
    acc = accuracy_score(y_test, y_pred)
    results[name] = acc
for model, acc in results.items():
    print(model, ":", round(acc, 3))
import pandas as pd

df_results = pd.DataFrame(list(results.items()), columns=["Model", "Accuracy"])
print(df_results)
import matplotlib.pyplot as plt

df_results.set_index("Model").plot(kind="bar")

plt.ylabel("Accuracy")
plt.title("Model Comparison for Stress Prediction")
plt.show()
import joblib

joblib.dump(rf_model,"random_forest_model.pkl")
print("Model saved successfully")
rfm = joblib.load("random_forest_model.pkl")
y_pred = rfm.predict(X_test_pca)
acc = accuracy_score(y_test, y_pred)
print(acc)
