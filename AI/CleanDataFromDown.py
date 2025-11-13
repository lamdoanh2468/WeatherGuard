import pandas as pd
import json

# --- Load CSV gốc bạn xuất từ Firebase ---
df = pd.read_csv('dht22_clean.csv')   # đổi lại tên file nếu cần

records = []

# --- Duyệt toàn bộ 11k cột, mỗi cột chứa 1 JSON ---
for col in df.columns:
    raw = df[col].iloc[0]

    try:
        # Firebase lưu JSON bằng dấu nháy đơn → đổi sang nháy kép cho đúng chuẩn
        fixed = raw.replace("'", '"')

        obj = json.loads(fixed)

        records.append(obj)
    except:
        # bỏ qua ô lỗi
        pass

# --- Convert thành DataFrame chuẩn dạng dọc ---
clean_df = pd.DataFrame(records)

# --- Xuất file sạch ---
clean_df.to_csv("dht22_final.csv", index=False)

print("leaning complete! File saved as dht22_final.csv")
