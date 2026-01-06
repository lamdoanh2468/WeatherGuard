#include <DHT.h>
#include <DHT_U.h>
#include <WiFi.h>
#include <WiFiClientSecure.h>
#include <HTTPClient.h>
#include <Wire.h>
#include <hd44780.h>
#include <hd44780ioClass/hd44780_I2Cexp.h>
#include "time.h"

// GPS
#include <TinyGPSPlus.h>
#include <HardwareSerial.h>

#define DHTPIN 4
#define DHTTYPE DHT22

// NTP
const char* ntpServer = "pool.ntp.org";
const long gmtOffset_sec = 7 * 3600;
const int daylightOffset_sec = 0;

// WiFi
const char* ssid = "Lam Duy2.4G";
const char* password = "22111996";

// Firebase
const String FIREBASE_URL = "https://dht11anddht22-14fb9-default-rtdb.asia-southeast1.firebasedatabase.app";

DHT dht(DHTPIN, DHTTYPE);
hd44780_I2Cexp lcd;

// GPS objects
TinyGPSPlus gps;
HardwareSerial GPS(2);
static const int GPS_RX = 16;  // ESP32 nhận từ TX GPS
static const int GPS_TX = 17;  // ESP32 gửi sang RX GPS

String getCurrentTime() {
  struct tm timeinfo;
  if (!getLocalTime(&timeinfo)) return "N/A";
  char buffer[30];
  strftime(buffer, 30, "%Y-%m-%d %H:%M:%S", &timeinfo);
  return String(buffer);
}
String formatDateDDMMYY(const String& dt) {
  // dt: "YYYY-MM-DD HH:MM:SS"
  if (dt.length() < 19) return "N/A";

  String yy = dt.substring(0, 4);   // YY
  String mm = dt.substring(5, 7);   // MM
  String dd = dt.substring(8, 10);  // DD
  String time = dt.substring(11);   // HH:MM:SS

  return dd + "/" + mm + "/" + yy + " " + time;
}
void setup() {
  Serial.begin(115200);
  dht.begin();

  // LCD 30x4
  int status = lcd.begin(20, 4);
  if (status) hd44780::fatalError(status);

  lcd.clear();
  lcd.print("Connecting WiFi");

  // GPS UART2
  GPS.begin(9600, SERIAL_8N1, GPS_RX, GPS_TX);

  // Connect WiFi
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
    lcd.print(".");
  }

  Serial.println("\nWiFi connected!");
  lcd.clear();
  lcd.print("WiFi connected");
  delay(800);

  configTime(gmtOffset_sec, daylightOffset_sec, ntpServer);
  Serial.println("Time configured!");

  struct tm timeinfo;
  while (!getLocalTime(&timeinfo)) {
    Serial.println("Waiting for NTP time sync...");
    delay(1000);
  }
  Serial.println("NTP time synced!");
}

void loop() {
  // ====== 1) Đọc GPS liên tục để parser không bị đói dữ liệu ======
  while (GPS.available()) {
    gps.encode(GPS.read());
  }

  // ====== 2) Đọc DHT ======
  float temp = dht.readTemperature();
  float hum = dht.readHumidity();

  if (isnan(temp) || isnan(hum)) {
    lcd.clear();
    lcd.print("Sensor error!");
    Serial.println("Failed to read from DHT!");
    delay(2000);
    return;
  }

  // ====== 3) Lấy time + GPS values ======
  String currentTime = getCurrentTime();
  time_t now = time(nullptr);

  bool hasFix = gps.location.isValid() && gps.location.age() < 5000;  // fix mới < 5s
  double lat = hasFix ? gps.location.lat() : 0.0;
  double lng = hasFix ? gps.location.lng() : 0.0;
  double alt = (hasFix && gps.altitude.isValid()) ? gps.altitude.meters() : 0.0;
  int sats = gps.satellites.isValid() ? gps.satellites.value() : 0;
  double hdop = gps.hdop.isValid() ? gps.hdop.hdop() : 99.99;

  // ====== 4) LCD 20x4 ======
  lcd.clear();

  // Line 0: Temp + Hum gọn
  lcd.setCursor(0, 0);
  lcd.print("T:");
  lcd.print(temp, 1);
  lcd.print((char)223);
  lcd.print("C ");
  lcd.print("H:");
  lcd.print(hum, 1);
  lcd.print("%");

  // Line 1-2: GPS
  lcd.setCursor(0, 1);
  if (hasFix) {
    lcd.print("Lat:");
    lcd.print(lat, 6);  // 6 số lẻ vẫn vừa
  } else {
    lcd.print("Lat: -- no fix --");
  }

  lcd.setCursor(0, 2);
  if (hasFix) {
    lcd.print("Lng:");
    lcd.print(lng, 6);
  } else {
    lcd.print("Lng: -- S:");
    lcd.print(sats);
    // đảm bảo không tràn quá 20 ký tự: phần này thường vẫn vừa
  }

  // Line 3: datetime rút gọn cho 20 ký tự
  // currentTime: "YYYY-MM-DD HH:MM:SS"
  // lấy "MM-DD HH:MM:SS" (14 ký tự) hoặc "YY-MM-DD HH:MM:SS" (17 ký tự)
  lcd.setCursor(0, 3);
  String dt = formatDateDDMMYY(currentTime);  // dd/mm/yy HH:MM:SS
  lcd.print(dt);
  lcd.print(" ");  // đệm để xoá ký tự thừa nếu có


  // ====== 5) Gửi Firebase ======
  if (WiFi.status() == WL_CONNECTED) {
    WiFiClientSecure client;
    client.setInsecure();

    HTTPClient http;
    String url = FIREBASE_URL + "/sensor_data.json";


    String jsonData = "{";
    jsonData += "\"temperature\":" + String(temp, 2) + ",";
    jsonData += "\"humidity\":" + String(hum, 1) + ",";
    jsonData += "\"timestamp\":" + String((long)now) + ",";
    jsonData += "\"lat\":" + String(lat, 6) + ",";
    jsonData += "\"lng\":" + String(lng, 6);
    jsonData += "}";

    Serial.println("[DEBUG] Sending to Firebase:");
    Serial.println(url);
    Serial.println(jsonData);

    if (http.begin(client, url)) {
      http.addHeader("Content-Type", "application/json");
      int httpResponseCode = http.POST(jsonData);

      if (httpResponseCode > 0) {
        Serial.print("[OK] Data sent! Code: ");
        Serial.println(httpResponseCode);
        Serial.println(http.getString());
      } else {
        Serial.print("[ERROR] HTTP POST failed, code: ");
        Serial.println(httpResponseCode);
      }
      http.end();
    } else {
      Serial.println("[ERROR] Failed to connect to Firebase URL");
    }
  } else {
    Serial.println("WiFi disconnected!");
    lcd.clear();
    lcd.print("WiFi lost...");
  }

  delay(5000);
}
