import firebase_admin
from firebase_admin import credentials
from firebase_admin import db
import time
import os

# === CẤU HÌNH ===
# Tên file key (đặt cùng thư mục với file python này)

# Lấy đường dẫn chính xác của thư mục chứa file code này
current_dir = os.path.dirname(os.path.abspath(__file__))

# Nối đường dẫn thư mục với tên file key
KEY_PATH = os.path.join(current_dir, "serviceAccountKey.json")# URL Database (Server Asia của bạn)
DB_URL = "https://dht11anddht22-14fb9-default-rtdb.asia-southeast1.firebasedatabase.app/"
# Tên node dữ liệu
NODE_NAME = "sensor_data"
# Giữ lại dữ liệu trong bao nhiêu ngày?
KEEP_DAYS = 30 

def main():
    # Kiểm tra xem file key có tồn tại không
    if not os.path.exists(KEY_PATH):
        print(f"❌ LỖI: Không tìm thấy file '{KEY_PATH}'. Hãy tải từ Firebase về và đổi tên lại.")
        return

    # Khởi tạo Firebase (chỉ khởi tạo 1 lần)
    if not firebase_admin._apps:
        cred = credentials.Certificate(KEY_PATH)
        firebase_admin.initialize_app(cred, {
            'databaseURL': DB_URL
        })

    ref = db.reference(NODE_NAME)
    
    # Tính thời gian mốc (miliseconds)
    # Hiện tại - (30 ngày * 24h * 60p * 60s * 1000ms)
    cutoff_time = int(time.time() * 1000) - (KEEP_DAYS * 24 * 60 * 60 * 1000)
    
    print(f"⏳ Đang quét dữ liệu cũ hơn {(KEEP_DAYS)} ngày trước...")
    
    # Query tìm dữ liệu cũ (Yêu cầu Database đã index theo timestamp)
    try:
        old_data_query = ref.order_by_child('timestamp').end_at(cutoff_time).get()
        
        if old_data_query:
            count = len(old_data_query)
            print(f"🔎 Tìm thấy {count} bản ghi cũ. Đang tiến hành xóa...")
            
            # Xóa từng cái (hoặc update null 1 cục để nhanh hơn)
            updates = {}
            for key in old_data_query:
                updates[key] = None # None nghĩa là xóa
            
            ref.update(updates)
            print(f"✅ Đã xóa thành công {count} bản ghi!")
        else:
            print("✅ Database sạch sẽ! Không có dữ liệu nào quá hạn.")
            
    except Exception as e:
        print(f"❌ Có lỗi xảy ra: {e}")
        print("Gợi ý: Kiểm tra lại Internet hoặc Rules trên Firebase.")

if __name__ == "__main__":
    main()