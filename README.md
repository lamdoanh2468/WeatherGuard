# 🌦️ IoT Weather & Environmental Monitoring System

## 📋 Giới thiệu

Hệ thống giám sát thời tiết và môi trường sử dụng IoT, tích hợp AI để dự báo và cảnh báo thời gian thực. Dự án kết hợp thiết bị IoT, backend xử lý dữ liệu với Spring Boot, và ứng dụng di động Flutter để trực quan hóa dữ liệu.

## 🎯 Tính năng chính

### 1. Thu thập Dữ liệu IoT 📡
- **Kết nối thiết bị IoT** (Raspberry Pi/ESP32) qua MQTT/HTTPS
- **Thu thập dữ liệu thời tiết**: Nhiệt độ, độ ẩm, áp suất, ánh sáng
- **Quản lý vị trí** thiết bị với tọa độ GPS
- **Giám sát trạng thái** thiết bị (online/offline, mức pin)

### 2. Xử lý Backend & AI 🧠
- **Lưu trữ dữ liệu lớn** từ hàng trăm/ngàn thiết bị IoT
- **Dự báo thời tiết ngắn hạn** sử dụng mô hình Time-Series
- **Cảnh báo ngưỡng tự động** khi chỉ số vượt mức an toàn
- **Hiệu chuẩn dữ liệu** với thuật toán xử lý outliers

### 3. Ứng dụng Di động 📲
- **Dashboard** hiển thị chỉ số hiện tại
- **Biểu đồ lịch sử** tương tác (giờ/ngày/tuần)
- **Bản đồ giám sát** vị trí các trạm theo thời gian thực
- **Thông báo push** cảnh báo thời tiết/môi trường

### 4. Quản lý Người dùng 👤
- Đăng ký/Đăng nhập với JWT Security
- Quản lý trạm cá nhân (thêm/xóa/sửa)
- Tùy chỉnh ngưỡng cảnh báo theo nhu cầu

## 🚀 Công nghệ sử dụng

### IoT & Hardware
- **Thiết bị**: Raspberry Pi, ESP32
- **Cảm biến**: DHT11/DHT22 (nhiệt độ/độ ẩm), BMP180 (áp suất), GPS module
- **Giao thức**: MQTT, HTTPS

### Backend
- **Framework**: Spring Boot (Microservices)
- **Database**: PostgreSQL / InfluxDB (Time-Series)
- **Cloud**: AWS IoT Core / Azure IoT Hub
- **Security**: JWT Authentication

### Mobile App
- **Framework**: Flutter
- **Charts**: fl_chart, charts_flutter
- **Maps**: Google Maps SDK / OpenStreetMap
- **Notifications**: Firebase Cloud Messaging

### AI/ML
- **Models**: Time-Series Forecasting
- **Integration**: Python scripts via Spring Boot services

## 📦 Cài đặt

### Yêu cầu hệ thống
- Node.js 16+
- Java 17+
- Flutter 3.0+
- Python 3.8+ (cho AI/ML)
- PostgreSQL 14+ hoặc InfluxDB 2.0+

### Backend Setup
```bash
# Clone repository
git clone https://github.com/your-username/iot-weather-system.git
cd iot-weather-system/backend

# Cài đặt dependencies
./mvnw clean install

# Cấu hình database trong application.properties
# Chạy ứng dụng
./mvnw spring-boot:run
```

### Mobile App Setup
```bash
cd mobile-app

# Cài đặt dependencies
flutter pub get

# Cấu hình Firebase
# Thêm google-services.json (Android) và GoogleService-Info.plist (iOS)

# Chạy ứng dụng
flutter run
```

### IoT Device Setup
```bash
cd iot-device

# Cài đặt thư viện Python
pip install -r requirements.txt

# Cấu hình kết nối MQTT trong config.json
# Chạy script thu thập dữ liệu
python main.py
```

## 🏗️ Kiến trúc hệ thống

```
┌─────────────┐         ┌──────────────┐         ┌─────────────┐
│ IoT Devices │ ──MQTT─→│ Cloud IoT    │ ──API─→ │   Backend   │
│  (Sensors)  │         │   Gateway    │         │ Spring Boot │
└─────────────┘         └──────────────┘         └──────┬──────┘
                                                         │
                                                         ↓
                                                  ┌──────────────┐
                                                  │   Database   │
                                                  │ PostgreSQL/  │
                                                  │  InfluxDB    │
                                                  └──────────────┘
                                                         ↑
                                                         │
┌─────────────┐                                         │
│  Flutter    │ ────────────── REST API ────────────────┘
│  Mobile App │
└─────────────┘
```

## 💡 Tính năng nâng cao (Advanced)

### N.1 Dự báo Chất lượng Không khí (AQI)
- Tích hợp cảm biến bụi PM2.5/PM10
- Mô hình hồi quy AI tính toán và dự báo chỉ số AQI

### N.2 Dự báo Dài hạn (3-7 ngày)
- Sử dụng Deep Learning (LSTM/GRU)
- Dự báo xu hướng thời tiết/môi trường

### N.3 Microservice Phân tích Dữ liệu Lớn
- Spring Boot WebFlux (Reactive Programming)
- Message Queue: Kafka/RabbitMQ
- Xử lý luồng dữ liệu liên tục

### N.4 Phân loại Mức độ Ô nhiễm
- AI Classification Model
- Phân loại: Tốt / Trung bình / Nguy hiểm

### N.5 Tối ưu hóa Hiển thị Bản đồ
- Map Clustering khi có nhiều trạm
- Geo-spatial Query optimization

## 📖 API Documentation

API documentation có sẵn tại: `http://localhost:8080/swagger-ui.html`

### Các endpoint chính:
- `POST /api/auth/register` - Đăng ký tài khoản
- `POST /api/auth/login` - Đăng nhập
- `GET /api/stations` - Lấy danh sách trạm giám sát
- `GET /api/data/current` - Dữ liệu thời tiết hiện tại
- `GET /api/data/history` - Dữ liệu lịch sử
- `GET /api/forecast` - Dự báo thời tiết
- `POST /api/alerts/config` - Cấu hình cảnh báo

## 🤝 Đóng góp

Mọi đóng góp đều được chào đón! Vui lòng:
1. Fork repository
2. Tạo branch mới (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Mở Pull Request

## 📝 License

Dự án này được phát hành dưới [MIT License](LICENSE).

## 👥 Nhóm phát triển

- **IoT Team**: Phát triển thiết bị và cảm biến
- **Backend Team**: Xây dựng API và xử lý dữ liệu
- **Mobile Team**: Phát triển ứng dụng Flutter
- **AI/ML Team**: Xây dựng mô hình dự báo

## 📞 Liên hệ

- Email: contact@iot-weather-system.com
- Website: https://iot-weather-system.com
- Issues: https://github.com/your-username/iot-weather-system/issues

---

⭐ Nếu dự án hữu ích, hãy cho chúng tôi một star trên GitHub!
