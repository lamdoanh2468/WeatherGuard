import requests
from fastapi import FastAPI
import pandas as pd
from utils import forecast_and_cluster

app = FastAPI()

FIREBASE_URL = "https://dht11anddht22-14fb9-default-rtdb.asia-southeast1.firebasedatabase.app/.json"
@app.get("/")
def home():
    return {"message": "API running OK!"}
@app.get("/realtime")
def realtime_forecast():

    # 1) Lấy toàn bộ data từ Firebase
    data = requests.get(FIREBASE_URL).json()

    if "sensor_data" not in data:
        return {"error": "Firebase không có nhánh sensor_data"}

    # LẤY ĐÚNG NHÁNH
    records = data["sensor_data"]

    df = pd.DataFrame.from_dict(records, orient="index")

    # 2) Làm sạch dữ liệu
    required_cols = ["temperature", "humidity", "timestamp"]
    df = df.dropna(subset=required_cols)

    # ép kiểu
    df["temperature"] = pd.to_numeric(df["temperature"], errors="coerce")
    df["humidity"] = pd.to_numeric(df["humidity"], errors="coerce")
    df["timestamp"] = pd.to_numeric(df["timestamp"], errors="coerce")

    # loại bỏ record bị lỗi khi convert
    df = df.dropna(subset=required_cols)

    if len(df) == 0:
        return {"error": "Không có record nào đạt chuẩn"}

    # 3) sort + lấy 60 bản ghi cuối
    df = df.sort_values("timestamp")
    df_last = df.tail(60)

    if len(df_last) < 60:
        return {"error": "Firebase chưa đủ 60 bản ghi"}

    # 4) Giữ đúng 2 field
    df_last = df_last[["temperature", "humidity"]]

    # 5) Dự báo & phân cụm
    output = forecast_and_cluster(df_last)

    return output
@app.get("/latest")
def get_latest_record():
    # Lấy toàn bộ data từ Firebase
    data = requests.get(FIREBASE_URL).json()

    if "sensor_data" not in data:
        return {"error": "Firebase không có nhánh sensor_data"}

    records = data["sensor_data"]

    df = pd.DataFrame.from_dict(records, orient="index")

    # Clean
    required_cols = ["temperature", "humidity", "timestamp"]
    df = df.dropna(subset=required_cols)

    df["temperature"] = pd.to_numeric(df["temperature"], errors="coerce")
    df["humidity"] = pd.to_numeric(df["humidity"], errors="coerce")
    df["timestamp"] = pd.to_numeric(df["timestamp"], errors="coerce")

    df = df.dropna(subset=required_cols)

    if len(df) == 0:
        return {"error": "Không có data hợp lệ"}

    # Lấy bản ghi mới nhất
    latest = df.sort_values("timestamp").iloc[-1]

    # Convert timestamp → datetime cho dễ xem
    from datetime import datetime
    readable_time = datetime.fromtimestamp(latest["timestamp"]).strftime("%Y-%m-%d %H:%M:%S")

    return {
        "temperature": latest["temperature"],
        "humidity": latest["humidity"],
        "timestamp": int(latest["timestamp"]),
        "datetime": readable_time
    }
@app.get("/stats")
def get_stats():
    data = requests.get(FIREBASE_URL).json()

    if "sensor_data" not in data:
        return {"error": "Firebase không có nhánh sensor_data"}

    df = pd.DataFrame.from_dict(data["sensor_data"], orient="index")

    required_cols = ["temperature", "humidity", "timestamp"]
    df = df.dropna(subset=required_cols)

    df["temperature"] = pd.to_numeric(df["temperature"], errors="coerce")
    df["humidity"] = pd.to_numeric(df["humidity"], errors="coerce")
    df = df.dropna(subset=required_cols)

    if df.empty:
        return {"error": "Không có data hợp lệ"}

    stats = {
        "temperature": {
            "min": df["temperature"].min(),
            "max": df["temperature"].max(),
            "avg": df["temperature"].mean()
        },
        "humidity": {
            "min": df["humidity"].min(),
            "max": df["humidity"].max(),
            "avg": df["humidity"].mean()
        },
        "records": len(df)
    }

    return stats
