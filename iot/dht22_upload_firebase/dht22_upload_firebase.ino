#include <DHT.h>
#include <WiFi.h>
#include <WiFiClientSecure.h>
#include <HTTPClient.h>
#include <Wire.h>
#include <hd44780.h>
#include <hd44780ioClass/hd44780_I2Cexp.h>
#include "time.h"

#define DHTPIN 4
#define DHTTYPE DHT22

// NTP
const char* ntpServer = "pool.ntp.org";
const long gmtOffset_sec = 7 * 3600;
const int daylightOffset_sec = 0;

// WiFi
const char* ssid = "Lam Duy2.4G";
const char* password = "22111996";

// Firebase (dùng push tự động tạo key)
const String FIREBASE_URL = 
  "https://dht11anddht22-14fb9-default-rtdb.asia-southeast1.firebasedatabase.app/sensor_data.json";

DHT dht(DHTPIN, DHTTYPE);
hd44780_I2Cexp lcd;

// LẤY THỜI GIAN
String getCurrentTime() {
  struct tm timeinfo;
  if (!getLocalTime(&timeinfo)) return "N/A";
  char buffer[30];
  strftime(buffer, sizeof(buffer), "%Y-%m-%d %H:%M:%S", &timeinfo);
  return String(buffer);
}

void setup() {
  Serial.begin(115200);
  dht.begin();

  int status = lcd.begin(16, 2);
  if (status) hd44780::fatalError(status);
  lcd.print("Connecting WiFi");

  // Connect WiFi
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }

  lcd.clear();
  lcd.print("WiFi connected");

  // NTP time
  configTime(gmtOffset_sec, daylightOffset_sec, ntpServer);
  delay(1000);
}

void loop() {
  // Nếu rớt WiFi → tự reconnect
  if (WiFi.status() != WL_CONNECTED) {
    Serial.println("WiFi lost! Reconnecting...");
    WiFi.reconnect();
    delay(2000);
    return;
  }

  float temp = dht.readTemperature();
  float hum = dht.readHumidity();

  // Sensor lỗi → bỏ vòng
  if (isnan(temp) || isnan(hum)) {
    Serial.println("DHT error!");
    lcd.setCursor(0,0); lcd.print("Sensor error!");
    delay(2000);
    return;
  }

  // LCD
  lcd.setCursor(0, 0);
  lcd.print("Nhiet do: ");
  lcd.print(temp);
  lcd.print((char)223);

  lcd.setCursor(0, 1);
  lcd.print("Do am: ");
  lcd.print(hum);
  lcd.print("%   ");

  // JSON gửi Firebase
  WiFiClientSecure client;
  client.setInsecure();

  HTTPClient http;
  http.setReuse(true);   // GIỮ KẾT NỐI

  String currentTime = getCurrentTime();
  unsigned long timestamp = time(nullptr);

  String jsonData =
    "{\"temperature\": " + String(temp) +
    ", \"humidity\": " + String(hum) +
    ", \"datetime\": \"" + currentTime + "\"" +
    ", \"timestamp\": " + String(timestamp) + "}";

  Serial.println("Sending:");
  Serial.println(jsonData);

  int httpCode = -1;

  // TRY 1
  if (http.begin(client, FIREBASE_URL)) {
    http.addHeader("Content-Type", "application/json");
    httpCode = http.POST(jsonData);
  }

  // TRY 2 nếu FAIL
  if (httpCode <= 0) {
    Serial.println("Retry sending...");
    delay(1000);
    httpCode = http.POST(jsonData);
  }

  if (httpCode > 0) {
    Serial.print("Firebase OK: ");
    Serial.println(httpCode);
  } else {
    Serial.print("Firebase ERROR: ");
    Serial.println(httpCode);
  }
  
  http.end();
  delay(8000); // tránh spam Firebase
}
