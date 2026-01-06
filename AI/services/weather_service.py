import os
import sys
import pickle
import numpy as np
import pandas as pd
from tensorflow.keras.models import load_model
from datetime import datetime

# Add parent directory to path to import config
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
import config
from services.firebase_service import FirebaseService

class WeatherService:
    def __init__(self):
        self.firebase_service = FirebaseService()
        self._load_models()
        self.cluster_text = {
            0: "Trời ổn định",
            1: "Nhiệt độ tăng, có xu hướng nóng hơn",
            2: "Nhiệt độ giảm, trời mát hơn",
            3: "Độ ẩm tăng, có khả năng trời sắp mưa",
            4: "Độ ẩm giảm, trời khô ráo hơn",
            5: "Biến động mạnh, thời tiết thất thường"
        }

    def _load_models(self):
        """Load ML models and scalers"""
        try:
            self.model = load_model(os.path.join(config.MODEL_DIR, "best_model.h5"), compile=False)
            with open(os.path.join(config.MODEL_DIR, "scaler.pkl"), "rb") as f:
                self.scaler = pickle.load(f)
            with open(os.path.join(config.MODEL_DIR, "kmeans.pkl"), "rb") as f:
                self.kmeans = pickle.load(f)
            print("Models loaded successfully")
        except Exception as e:
            print(f"Error loading models: {e}")
            self.model = None
            self.scaler = None
            self.kmeans = None

    def _extract_features_for_clustering(self, seq):
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

    def _prepare_dataframe(self, records):
        if not records:
            return pd.DataFrame()
        
        df = pd.DataFrame.from_dict(records, orient="index")
        
        required_cols = ["temperature", "humidity", "timestamp"]
        # Check if columns exist
        if not all(col in df.columns for col in required_cols):
            return pd.DataFrame()

        df = df.dropna(subset=required_cols)
        
        # Determine strictness of numeric conversion based on column data types
        # Using coerce to handle any non-numeric data gracefully
        df["temperature"] = pd.to_numeric(df["temperature"], errors="coerce")
        df["humidity"] = pd.to_numeric(df["humidity"], errors="coerce")
        df["timestamp"] = pd.to_numeric(df["timestamp"], errors="coerce")

        df = df.dropna(subset=required_cols)
        return df

    def get_realtime_forecast(self):
        records = self.firebase_service.fetch_sensor_data()
        if not records:
            return {"error": "Không có dữ liệu sensor"}

        df = self._prepare_dataframe(records)
        if df.empty:
            return {"error": "Không có dữ liệu hợp lệ"}

        df = df.sort_values("timestamp")
        df_last = df.tail(60)

        if len(df_last) < 60:
            return {"error": "Chưa đủ 60 bản ghi để dự báo"}

        # Prepare for prediction
        df_last = df_last[["temperature", "humidity"]]
        arr = df_last.values

        if self.model is None:
            return {"error": "Model chưa được load"}

        # Predict
        arr_scaled = self.scaler.transform(arr)
        x_input = np.expand_dims(arr_scaled, axis=0)
        
        y_scaled = self.model.predict(x_input)
        y_future = self.scaler.inverse_transform(y_scaled)[0]

        # Cluster
        feats = self._extract_features_for_clustering(arr_scaled)
        c_id = int(self.kmeans.predict(feats)[0])
        
        return {
            "temp_15m": float(y_future[0]),
            "humid_15m": float(y_future[1]),
            "cluster_id": c_id,
            "cluster_text": self.cluster_text.get(c_id, "Không xác định")
        }

    def get_latest_record(self):
        records = self.firebase_service.fetch_sensor_data()
        if not records:
            return {"error": "Không có dữ liệu"}

        df = self._prepare_dataframe(records)
        if df.empty:
            return {"error": "Không có dữ liệu hợp lệ"}

        latest = df.sort_values("timestamp").iloc[-1]
        readable_time = datetime.fromtimestamp(latest["timestamp"]).strftime("%Y-%m-%d %H:%M:%S")

        return {
            "temperature": float(latest["temperature"]),
            "humidity": float(latest["humidity"]),
            "timestamp": int(latest["timestamp"]),
            "datetime": readable_time
        }

    def get_stats(self):
        records = self.firebase_service.fetch_sensor_data()
        if not records:
            return {"error": "Không có dữ liệu"}

        df = self._prepare_dataframe(records)
        if df.empty:
            return {"error": "Không có dữ liệu hợp lệ"}

        return {
            "temperature": {
                "min": float(df["temperature"].min()),
                "max": float(df["temperature"].max()),
                "avg": round(float(df["temperature"].mean()), 1)
            },
            "humidity": {
                "min": float(df["humidity"].min()),
                "max": float(df["humidity"].max()),
                "avg": round(float(df["humidity"].mean()), 1)
            },
            "records": len(df)
        }

    def get_alerts(self, temp_high_threshold: float = None):
        records = self.firebase_service.fetch_sensor_data()
        if not records:
            return {"status": "unknown", "message": "Không có dữ liệu"}

        df = self._prepare_dataframe(records)
        if df.empty:
            return {"status": "unknown", "message": "Dữ liệu lỗi"}

        latest = df.sort_values("timestamp").iloc[-1]
        temp = float(latest["temperature"])
        hum = float(latest["humidity"])

        alerts = []
        status_level = "normal"

        # Determine threshold to use
        limit_high = temp_high_threshold if temp_high_threshold is not None else config.TEMP_HIGH_DANGER

        # Temperature Logic
        if temp >= limit_high:
            alerts.append(f"🔥 NGUY HIỂM: Nhiệt độ vượt ngưỡng ({temp}°C >= {limit_high}°C)")
            status_level = "danger"
        elif temp >= config.TEMP_HIGH_WARN and (temp_high_threshold is None or temp < limit_high):
            # Only show warning if not already in danger (custom threshold)
            alerts.append(f"⚠️ Cảnh báo: Trời nóng ({temp}°C)")
            if status_level != "danger": status_level = "warning"
        elif temp <= config.TEMP_LOW_WARN:
            alerts.append(f"❄️ Cảnh báo: Trời lạnh ({temp}°C)")
            if status_level != "danger": status_level = "warning"

        # Humidity Logic
        if hum >= config.HUM_HIGH_WARN:
            alerts.append(f"💧 Độ ẩm quá cao ({hum}%) - Coi chừng nồm mốc")
            if status_level != "danger": status_level = "warning"
        elif hum <= config.HUM_LOW_WARN:
            alerts.append(f"🌵 Độ ẩm quá thấp ({hum}%) - Khô hanh")
            if status_level != "danger": status_level = "warning"

        # Combo Logic
        if temp > 38 and hum < 30:
            alerts.insert(0, "🆘 BÁO ĐỘNG: Nguy cơ hỏa hoạn cao!")
            status_level = "danger"

        return {
            "status_level": status_level,
            "has_alert": len(alerts) > 0,
            "messages": alerts,
            "data": {
                "temp": temp,
                "hum": hum
            }
        }

    def check_health(self):
        firebase_status = "OK" if self.firebase_service.check_connection() else "OFFLINE"
        model_status = "OK" if self.model is not None else "ERROR"
        return {
            "status": "running",
            "firebase": firebase_status,
            "models": model_status
        }
