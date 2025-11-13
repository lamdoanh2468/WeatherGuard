import pandas as pd
import matplotlib.pyplot as plt

# Load labeled file
df = pd.read_csv("dht22_kmeans_6label.csv")

# 1) Thống kê số lượng mỗi cluster
counts = df["kmeans_label"].value_counts().sort_index()
print("Cluster counts:")
print(counts)

# 2) Show vài dòng mẫu
print("\nSample rows:")
print(df[["datetime","temperature","humidity","kmeans_label"]].head(10).to_string(index=False))

# 3) Scatter plot Temperature vs Humidity (colored by cluster index)
plt.figure(figsize=(8,5))
for label in sorted(df["kmeans_label"].unique()):
    subset = df[df["kmeans_label"]==label]
    plt.scatter(subset["temperature"], subset["humidity"], label=f"c{label}", s=10, marker='o')
plt.xlabel("temperature")
plt.ylabel("humidity")
plt.title("Temperature vs Humidity — KMeans 6 clusters")
plt.legend(title="cluster", bbox_to_anchor=(1.05, 1), loc='upper left')
plt.tight_layout()
plt.show()
