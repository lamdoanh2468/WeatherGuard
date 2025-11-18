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
            "avg": df["temperature"].mean().__round__(1)
        },
        "humidity": {
            "min": df["humidity"].min(),
            "max": df["humidity"].max(),
            "avg": df["humidity"].mean().__round__(1)
        },
        "records": len(df)
    }

    return stats

@app.get("/health")
def health_check():
    """Kiểm tra Firebase kết nối OK không"""
    try:
        response = requests.get(FIREBASE_URL, timeout=5)
        firebase_status = "OK" if response.status_code == 200 else "ERROR"
    except:
        firebase_status = "OFFLINE"
    
    return {
        "status": "running",
        "firebase": firebase_status
    }
@app.get("/alerts")
def get_alerts():
    # --- BƯỚC 1: LẤY DỮ LIỆU MỚI NHẤT ---
    data = requests.get(FIREBASE_URL).json()
    if not data or "sensor_data" not in data:
        return {"status": "unknown", "message": "Không có dữ liệu"}

    df = pd.DataFrame.from_dict(data["sensor_data"], orient="index")

    if df.empty:
        return {"status": "unknown", "message": "Dữ liệu lỗi"}

    latest = df.sort_values("timestamp").iloc[-1]
    temp = float(latest["temperature"])
    hum = float(latest["humidity"])

    # --- BƯỚC 2: LOGIC CẢNH BÁO ---
    alerts = []
    
    TEMP_HIGH_DANGER =37
    TEMP_HIGH_WARN = 33
    TEMP_LOW_WARN = 26

    HUM_HIGH_WARN =80
    HUM_LOW_WARN = 20
    status_level = "normal"  # Mặc định là bình thường (green)

    # Logic 1: Kiểm tra Nhiệt độ
    if temp >= TEMP_HIGH_DANGER:
        alerts.append(f"🔥 NGUY HIỂM: Nhiệt độ rất cao ({temp}°C)")
        status_level = "danger" # Mức cao nhất -> Đỏ
    elif temp >= TEMP_HIGH_WARN:
        alerts.append(f"⚠️ Cảnh báo: Trời nóng ({temp}°C)")
        if status_level != "danger": status_level = "warning" # Vàng

    elif temp <= TEMP_LOW_WARN:
        alerts.append(f"❄️ Cảnh báo: Trời lạnh ({temp}°C)")
        if status_level != "danger": status_level = "warning"

    # Logic 2: Kiểm tra Độ ẩm
    if hum >= HUM_HIGH_WARN:
        alerts.append(f"💧 Độ ẩm quá cao ({hum}%) - Coi chừng nồm mốc")
        if status_level != "danger": status_level = "warning"
    elif hum <= HUM_LOW_WARN:
        alerts.append(f"🌵 Độ ẩm quá thấp ({hum}%) - Khô hanh")
        if status_level != "danger": status_level = "warning"

    # Logic 3: Cảnh báo Phức hợp (Combo nguy hiểm nhất)
    # Ví dụ: Nhiệt cao > 38 VÀ Ẩm thấp < 30 => Nguy cơ cháy rừng/hỏa hoạn cao
    if temp > 38 and hum < 30:
        alerts.insert(0, "🆘 BÁO ĐỘNG: Nguy cơ hỏa hoạn cao!") # Đẩy lên đầu
        status_level = "danger"

    # --- BƯỚC 3: TRẢ VỀ KẾT QUẢ ---
    return {
        "status_level": status_level, # normal | warning | danger
        "has_alert": len(alerts) > 0,
        "messages": alerts,
        "data": {
            "temp": temp,
            "hum": hum
        }
    }