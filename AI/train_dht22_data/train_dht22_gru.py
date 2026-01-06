# -*- coding: utf-8 -*-
"""train_dht22_data_time_series_gru"""

# =========================
# 1. IMPORT LIBS
# =========================
import numpy as np
import pandas as pd
import os
from sklearn.preprocessing import StandardScaler
from sklearn.cluster import KMeans
from sklearn.model_selection import train_test_split

import tensorflow as tf
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import GRU, Dense, Dropout, Bidirectional

from sklearn.metrics import mean_absolute_error, mean_squared_error, r2_score
from prettytable import PrettyTable
import pickle

# =========================
# 2. HYPERPARAMS
# =========================
WINDOW_MINUTES = 60
HORIZON_MINUTES = 15
N_CLUSTERS = 6
RANDOM_STATE = 42

# =========================
# 3. LOAD & PREPROCESS DATA
# =========================
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
csv_path = os.path.join(BASE_DIR, "..", "DHT22_DATA", "dht22_clean_processed.csv")
df = pd.read_csv(csv_path)

df["datetime"] = pd.to_datetime(df["datetime"])
df = df.sort_values("datetime")

df_resampled = (
    df.set_index("datetime")
      .resample("1min")
      .mean()
      .interpolate()
)

df_resampled["humidity"] = (
    df_resampled["humidity"]
      .rolling(3, center=True)
      .mean()
)

df_resampled = df_resampled.dropna(subset=["temperature", "humidity"])

data = df_resampled[["temperature", "humidity"]].copy()

scaler = StandardScaler()
data_scaled = scaler.fit_transform(data.values)

print("Data shape:", data_scaled.shape)

# =========================
# 4. BUILD SEQUENCES
# =========================
def build_sequences(data_array, window_size, horizon):
    X, y = [], []
    n = len(data_array)
    for i in range(n - window_size - horizon + 1):
        X.append(data_array[i:i+window_size])
        y.append(data_array[i+window_size+horizon-1])
    return np.array(X), np.array(y)

X, y = build_sequences(data_scaled, WINDOW_MINUTES, HORIZON_MINUTES)

# =========================
# 5. CLUSTERING FEATURES
# =========================
def extract_features_for_clustering(X_seq):
    feats = []
    for seq in X_seq:
        temp = seq[:, 0]
        hum = seq[:, 1]
        feats.append([
            temp.mean(), temp.std(),
            hum.mean(), hum.std(),
            temp[-1] - temp[0],
            hum[-1] - hum[0]
        ])
    return np.array(feats)

X_feats = extract_features_for_clustering(X)

kmeans = KMeans(
    n_clusters=N_CLUSTERS,
    random_state=RANDOM_STATE,
    n_init=10
)
cluster_labels = kmeans.fit_predict(X_feats)

# =========================
# 6. TRAIN / TEST SPLIT
# =========================
X_train, X_test, y_train, y_test, cl_train, cl_test = train_test_split(
    X, y, cluster_labels, test_size=0.2, shuffle=False
)

# =========================
# 7. BUILD GRU MODEL 🔥
# =========================
n_timesteps = X_train.shape[1]
n_features = X_train.shape[2]
output_size = y_train.shape[1]

model = Sequential([
    tf.keras.Input(shape=(n_timesteps, n_features)),
    Bidirectional(GRU(64, return_sequences=False)),
    Dropout(0.2),
    Dense(32, activation="relu"),
    Dense(output_size)
])

model.compile(
    optimizer=tf.keras.optimizers.Adam(1e-3),
    loss="mse",
    metrics=["mae"]
)

model.summary()

# =========================
# 8. TRAIN MODEL
# =========================
callback = tf.keras.callbacks.EarlyStopping(
    monitor="val_loss",
    patience=5,
    restore_best_weights=True
)

model.fit(
    X_train, y_train,
    validation_data=(X_test, y_test),
    epochs=100,
    batch_size=32,
    callbacks=[callback],
    verbose=1
)

# =========================
# 9. EVALUATION
# =========================
y_pred = model.predict(X_test)

y_test_real = scaler.inverse_transform(y_test)
y_pred_real = scaler.inverse_transform(y_pred)

def calc_metrics(y_true, y_pred):
    mae = mean_absolute_error(y_true, y_pred)
    mse = mean_squared_error(y_true, y_pred)
    rmse = np.sqrt(mse)
    r2 = r2_score(y_true, y_pred)
    return mae, mse, rmse, r2

metrics_temp = calc_metrics(y_test_real[:,0], y_pred_real[:,0])
metrics_hum  = calc_metrics(y_test_real[:,1], y_pred_real[:,1])

table = PrettyTable()
table.field_names = ["Metric", "Temperature", "Humidity"]
table.add_row(["MAE",  f"{metrics_temp[0]:.4f}", f"{metrics_hum[0]:.4f}"])
table.add_row(["MSE",  f"{metrics_temp[1]:.4f}", f"{metrics_hum[1]:.4f}"])
table.add_row(["RMSE", f"{metrics_temp[2]:.4f}", f"{metrics_hum[2]:.4f}"])
table.add_row(["R2",   f"{metrics_temp[3]:.4f}", f"{metrics_hum[3]:.4f}"])

print("\n=== GRU MODEL METRICS ===")
print(table)

# =========================
# 10. SAVE MODEL & OBJECTS
# =========================
os.makedirs("models", exist_ok=True)

model.save("models/gru_model.h5")

with open("models/gru_scaler.pkl", "wb") as f:
    pickle.dump(scaler, f)

with open("models/gru_kmeans.pkl", "wb") as f:
    pickle.dump(kmeans, f)
    
# Lưu bảng kết quả vào file text
result_path = "gru_training_results.txt"
with open(result_path, "w", encoding="utf-8") as f:
    f.write("=== KẾT QUẢ ĐÁNH GIÁ MÔ HÌNH ===\n")
    f.write(table.get_string()) # Lấy nội dung bảng thành chuỗi
    f.write("\n\n")

print(f"\n[INFO] Đã lưu bảng kết quả vào file: {result_path}")

input("\nĐã chạy xong. Nhấn Enter để thoát...")