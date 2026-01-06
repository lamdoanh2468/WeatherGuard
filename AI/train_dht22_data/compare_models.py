# -*- coding: utf-8 -*-
"""
compare_models.py
Script so sánh trực tiếp LSTM vs GRU cho dữ liệu DHT22
"""

import numpy as np
import pandas as pd
import os
import time
import pickle
import matplotlib.pyplot as plt
from prettytable import PrettyTable

from sklearn.preprocessing import MinMaxScaler
from sklearn.cluster import KMeans
from sklearn.model_selection import train_test_split
from sklearn.metrics import mean_absolute_error, mean_squared_error, r2_score

import tensorflow as tf
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import LSTM, GRU, Dense, Dropout, Bidirectional

# =========================
# 1. CẤU HÌNH (HYPERPARAMS)
# =========================
WINDOW_MINUTES = 60
HORIZON_MINUTES = 15
N_CLUSTERS = 6
RANDOM_STATE = 42
EPOCHS = 100 # Để demo, thực tế sẽ dừng sớm nhờ EarlyStopping
BATCH_SIZE = 32

# Đường dẫn data (như file cũ của bạn)
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
# Giả định folder DHT22_DATA nằm ngang hàng folder chứa code này
CSV_PATH = os.path.join(BASE_DIR, "..", "DHT22_DATA", "dht22_clean_processed.csv")
MODELS_DIR = os.path.join(BASE_DIR, "..", "models_comparison")

os.makedirs(MODELS_DIR, exist_ok=True)

# =========================
# 2. HÀM XỬ LÝ DỮ LIỆU CHUNG
# =========================
# ... (Các phần import ở trên giữ nguyên, nhớ đổi import StandardScaler thành MinMaxScaler)
from sklearn.preprocessing import MinMaxScaler  # <--- SỬA DÒNG NÀY

def load_and_process_data():
    print("[1/6] Loading & Processing Data...")
    if not os.path.exists(CSV_PATH):
        raise FileNotFoundError(f"Không tìm thấy file data tại: {CSV_PATH}")

    df = pd.read_csv(CSV_PATH)
    df["datetime"] = pd.to_datetime(df["datetime"])
    df = df.sort_values("datetime")

    # Resample & Interpolate
    df_resampled = df.set_index("datetime").resample("1min").mean().interpolate()
    
    # Rolling mean cho humidity
    df_resampled["humidity"] = df_resampled["humidity"].rolling(3, center=True).mean()
    df_resampled = df_resampled.dropna(subset=["temperature", "humidity"])

    # Scale data
    data = df_resampled[["temperature", "humidity"]].values
    
    # Dùng MinMaxScaler giúp đưa dữ liệu về khoảng [0, 1], 
    # giúp mạng Neural Network dễ học biên độ gốc hơn.
    scaler = MinMaxScaler(feature_range=(0, 1)) 
    data_scaled = scaler.fit_transform(data)
    # -----------------------------------
    
    return data_scaled, scaler

def build_sequences(data_array, window_size, horizon):
    X, y = [], []
    n = len(data_array)
    for i in range(n - window_size - horizon + 1):
        X.append(data_array[i : i + window_size])
        y.append(data_array[i + window_size + horizon - 1])
    return np.array(X), np.array(y)

# =========================
# 3. BUILD MODEL FUNCTIONS
# =========================
def create_model_lstm(input_shape, output_size):
    model = Sequential([
        tf.keras.Input(shape=input_shape),
        Bidirectional(LSTM(64, return_sequences=False)),
        Dropout(0.2),
        Dense(32, activation="relu"),
        Dense(output_size)
    ], name="LSTM_Model")
    model.compile(optimizer=tf.keras.optimizers.Adam(1e-3), loss="mse", metrics=["mae"])
    return model

def create_model_gru(input_shape, output_size):
    model = Sequential([
        tf.keras.Input(shape=input_shape),
        Bidirectional(GRU(64, return_sequences=False)),
        Dropout(0.2),
        Dense(32, activation="relu"),
        Dense(output_size)
    ], name="GRU_Model")
    model.compile(optimizer=tf.keras.optimizers.Adam(1e-3), loss="mse", metrics=["mae"])
    return model

# =========================
# 4. QUY TRÌNH CHÍNH
# =========================
# A. Load Data
data_scaled, scaler = load_and_process_data()
# =========================
# CLUSTERING (FIT KMEANS)
# =========================
def extract_features_for_clustering(seq_60x2):
    temp = seq_60x2[:, 0]
    humid = seq_60x2[:, 1]
    return [
        temp.mean(),
        temp.std(),
        humid.mean(),
        humid.std(),
        temp[-1] - temp[0],
        humid[-1] - humid[0],
    ]

# Tạo feature từ các cửa sổ 60 phút trên toàn bộ data
features = []
for i in range(len(data_scaled) - WINDOW_MINUTES + 1):
    window = data_scaled[i:i + WINDOW_MINUTES]  # (60,2)
    features.append(extract_features_for_clustering(window))

features = np.array(features)  # (n_windows, 6)

kmeans = KMeans(n_clusters=N_CLUSTERS, random_state=RANDOM_STATE, n_init=10)
kmeans.fit(features)
print("✅ KMeans fitted. Feature shape:", features.shape)

X, y = build_sequences(data_scaled, WINDOW_MINUTES, HORIZON_MINUTES)

# Split Train/Test (Shuffle=False cho time-series)
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, shuffle=False, random_state=RANDOM_STATE)

print(f"Data shape: Train={X_train.shape}, Test={X_test.shape}")

# Callback chung
early_stop = tf.keras.callbacks.EarlyStopping(monitor="val_loss", patience=5, restore_best_weights=True)

input_shape = (X_train.shape[1], X_train.shape[2])
output_size = y_train.shape[1]

# B. Train LSTM
print("\n[2/6] Training LSTM Model...")
lstm_model = create_model_lstm(input_shape, output_size)
start_lstm = time.time()
hist_lstm = lstm_model.fit(
    X_train, y_train, validation_data=(X_test, y_test),
    epochs=EPOCHS, batch_size=BATCH_SIZE, callbacks=[early_stop], verbose=0
)
time_lstm = time.time() - start_lstm
print(f"-> LSTM Training Time: {time_lstm:.2f}s | Best Val Loss: {min(hist_lstm.history['val_loss']):.4f}")

# C. Train GRU
print("\n[3/6] Training GRU Model...")
gru_model = create_model_gru(input_shape, output_size)
start_gru = time.time()
hist_gru = gru_model.fit(
    X_train, y_train, validation_data=(X_test, y_test),
    epochs=EPOCHS, batch_size=BATCH_SIZE, callbacks=[early_stop], verbose=0
)
time_gru = time.time() - start_gru
print(f"-> GRU Training Time:  {time_gru:.2f}s | Best Val Loss: {min(hist_gru.history['val_loss']):.4f}")

# =========================
# 5. ĐÁNH GIÁ VÀ SO SÁNH
# =========================
print("\n[4/6] Evaluating & Generating Report...")

# Predict
pred_lstm_scaled = lstm_model.predict(X_test, verbose=0)
pred_gru_scaled = gru_model.predict(X_test, verbose=0)

# Inverse Scale
y_test_real = scaler.inverse_transform(y_test)
pred_lstm_real = scaler.inverse_transform(pred_lstm_scaled)
pred_gru_real = scaler.inverse_transform(pred_gru_scaled)

# Hàm tính metrics
def calculate_metrics(y_true, y_pred, model_name):
    # Temp
    mae_t = mean_absolute_error(y_true[:,0], y_pred[:,0])
    rmse_t = np.sqrt(mean_squared_error(y_true[:,0], y_pred[:,0]))
    r2_t = r2_score(y_true[:,0], y_pred[:,0])
    # Humid
    mae_h = mean_absolute_error(y_true[:,1], y_pred[:,1])
    rmse_h = np.sqrt(mean_squared_error(y_true[:,1], y_pred[:,1]))
    r2_h = r2_score(y_true[:,1], y_pred[:,1])
    
    return [model_name, 
            f"{mae_t:.4f}", f"{rmse_t:.4f}", f"{r2_t:.4f}", 
            f"{mae_h:.4f}", f"{rmse_h:.4f}", f"{r2_h:.4f}"]

# Tạo bảng
table = PrettyTable()
table.field_names = ["Model", "Temp MAE", "Temp RMSE", "Temp R2", "Hum MAE", "Hum RMSE", "Hum R2"]
table.add_row(calculate_metrics(y_test_real, pred_lstm_real, "LSTM"))
table.add_row(calculate_metrics(y_test_real, pred_gru_real, "GRU"))

print("\n=== BẢNG SO SÁNH HIỆU SUẤT ===")
print(table)
print(f"Training Time Comparison: LSTM={time_lstm:.2f}s vs GRU={time_gru:.2f}s")
if time_gru < time_lstm:
    print(f"=> GRU nhanh hơn {time_lstm - time_gru:.2f} giây ({((time_lstm-time_gru)/time_lstm)*100:.1f}%)")

# =========================
# 6. VẼ BIỂU ĐỒ (VISUALIZATION)
# =========================
print("\n[5/6] Plotting results...")
# Lấy 150 điểm cuối để vẽ cho dễ nhìn
samples = 150
idx = range(samples)

plt.figure(figsize=(14, 6))

# Plot Temperature
plt.subplot(1, 2, 1)
plt.plot(y_test_real[-samples:, 0], label="Thực tế", color="black", linestyle="--", linewidth=1.5)
plt.plot(pred_lstm_real[-samples:, 0], label="LSTM", color="blue", alpha=0.7)
plt.plot(pred_gru_real[-samples:, 0], label="GRU", color="red", alpha=0.7)
plt.title(f"So sánh Nhiệt độ (Temp) - {samples} phút cuối")
plt.xlabel("Thời gian (phút)")
plt.ylabel("Độ C")
plt.legend()
plt.grid(True, alpha=0.3)

# Plot Humidity
plt.subplot(1, 2, 2)
plt.plot(y_test_real[-samples:, 1], label="Thực tế", color="black", linestyle="--", linewidth=1.5)
plt.plot(pred_lstm_real[-samples:, 1], label="LSTM", color="blue", alpha=0.7)
plt.plot(pred_gru_real[-samples:, 1], label="GRU", color="red", alpha=0.7)
plt.title(f"So sánh Độ ẩm (Humidity) - {samples} phút cuối")
plt.xlabel("Thời gian (phút)")
plt.ylabel("%")
plt.legend()
plt.grid(True, alpha=0.3)

plt.tight_layout()
plot_path = os.path.join(MODELS_DIR, "comparison_plot.png")
plt.savefig(plot_path)
print(f"Đã lưu biểu đồ so sánh tại: {plot_path}")

# =========================
# 7. LƯU MODELS
# =========================
print("\n[6/6] Saving models...")
best_lstm = min(hist_lstm.history["val_loss"])
best_gru  = min(hist_gru.history["val_loss"])

if best_gru < best_lstm:
    best_model = gru_model
    best_name = "GRU"
else:
    best_model = lstm_model
    best_name = "LSTM"

best_model.save(os.path.join(MODELS_DIR, "best_model.h5"))

with open(os.path.join(MODELS_DIR, "best_model_name.txt"), "w") as f:
    f.write(best_name)
    
# Save scaler + kmeans for realtime API
with open(os.path.join(MODELS_DIR, "scaler.pkl"), "wb") as f:
    pickle.dump(scaler, f)

with open(os.path.join(MODELS_DIR, "kmeans.pkl"), "wb") as f:
    pickle.dump(kmeans, f)