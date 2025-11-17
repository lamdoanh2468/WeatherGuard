import pandas as pd
import numpy as np
from sklearn.preprocessing import StandardScaler

# ==========================
# 1. READ FILE
# ==========================
df = pd.read_csv("dht22_final.csv")

# ==========================
# 2. CLEANING 
# ==========================

# Xóa dòng trùng lặp
df = df.drop_duplicates()

# Xóa dòng thiếu dữ liệu
df = df.dropna(subset=["temperature", "humidity"])

# Loại giá trị không hợp lệ
df = df[
    (df["temperature"] > -40) & (df["temperature"] < 80) &
    (df["humidity"] >= 0) & (df["humidity"] <= 100)
]

# ==========================
# 3. LOẠI OUTLIER (IQR)
# ==========================
def remove_outlier_iqr(data, column):
    Q1 = data[column].quantile(0.25)
    Q3 = data[column].quantile(0.75)
    IQR = Q3 - Q1
    lower = Q1 - 1.5 * IQR
    upper = Q3 + 1.5 * IQR
    return data[(data[column] >= lower) & (data[column] <= upper)]

df = remove_outlier_iqr(df, "temperature")
df = remove_outlier_iqr(df, "humidity")

# ==========================
# 4. CHUẨN HÓA DATA (StandardScaler)
# ==========================
scaler = StandardScaler()

df[["temperature_norm", "humidity_norm"]] = scaler.fit_transform(
    df[["temperature", "humidity"]]
)

# ==========================
# 5. LƯU FILE MỚI
# ==========================
df.to_csv("dht22_clean_processed.csv", index=False)

print("✔ File cleaned & processed saved as dht22_clean_processed.csv")
