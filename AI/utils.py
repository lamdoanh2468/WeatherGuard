import os
import numpy as np
import pandas as pd
import pickle
import tensorflow as tf
from tensorflow.keras.models import load_model

# =========================
# LOAD MODEL (from training)
# =========================
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
MODEL_DIR = os.path.join(BASE_DIR, "models")

model = load_model(os.path.join(MODEL_DIR, "lstm_model.h5"), compile=False)

with open(os.path.join(MODEL_DIR, "scaler.pkl"), "rb") as f:
    scaler = pickle.load(f)

with open(os.path.join(MODEL_DIR, "kmeans.pkl"), "rb") as f:
    kmeans = pickle.load(f)

# =========================
# CLUSTER TEXT MAPPING
# =========================
CLUSTER_TEXT = {
    0: "Trời ổn định",
    1: "Nhiệt độ tăng, có xu hướng nóng hơn",
    2: "Nhiệt độ giảm, trời mát hơn",
    3: "Độ ẩm tăng, có khả năng trời sắp mưa",
    4: "Độ ẩm giảm, trời khô ráo hơn",
    5: "Biến động mạnh, thời tiết thất thường"
}

# =========================
# FEATURE EXTRACTION
# =========================
def extract_features_for_clustering(seq):
    temp = seq[:, 0]
    humid = seq[:, 1]
    return np.array([[
        temp.mean(),
        temp.std(),
        humid.mean(),
        humid.std(),
        temp[-1] - temp[0],
        humid[-1] - humid[0],
    ]])

# =========================
# FORECAST API FUNCTION
# =========================
def forecast_and_cluster(last_60_df):
    arr = last_60_df[["temperature", "humidity"]].values

    # scale
    arr_scaled = scaler.transform(arr)

    # reshape
    x_input = np.expand_dims(arr_scaled, axis=0)

    # LSTM predict
    y_scaled = model.predict(x_input)
    y_future = scaler.inverse_transform(y_scaled)[0]

    # cluster
    feats = extract_features_for_clustering(arr_scaled)
    c_id = int(kmeans.predict(feats)[0])
    c_text = CLUSTER_TEXT[c_id]

    return {
        "temp_15m": float(y_future[0]),
        "humid_15m": float(y_future[1]),
        "cluster_id": c_id,
        "cluster_text": c_text
    }
