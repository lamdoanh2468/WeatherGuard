import pandas as pd
from sklearn.preprocessing import StandardScaler
from sklearn.cluster import KMeans

# Load file
df = pd.read_csv("dht22_clean_processed.csv")

# Select features
X = df[["temperature", "humidity"]]

# Scale features
scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)

# KMeans clustering (6 clusters)
kmeans = KMeans(n_clusters=6, random_state=42)
df["kmeans_label"] = kmeans.fit_predict(X_scaled)

# Save new file
df.to_csv("dht22_kmeans_6label.csv", index=False)
print("Saved: dht22_kmeans_6label.csv")
