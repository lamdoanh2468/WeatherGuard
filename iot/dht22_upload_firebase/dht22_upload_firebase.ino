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

// Firebase
const String FIREBASE_URL = "https://dht11anddht22-14fb9-default-rtdb.asia-southeast1.firebasedatabase.app";

DHT dht(DHTPIN, DHTTYPE);
hd44780_I2Cexp lcd;

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
  lcd.clear();
  lcd.print("Connecting WiFi");

  // Connect WiFi
  WiFi.begin(ssid, password);
  int dotPos = 0;
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
    lcd.setCursor(dotPos, 1);
    lcd.print(".");
    dotPos = (dotPos + 1) % 16;
  }

  Serial.println("\nWiFi connected!");
  lcd.clear();
  lcd.print("WiFi connected");
  delay(1000);

  // Configure NTP
  configTime(gmtOffset_sec, daylightOffset_sec, ntpServer);
  Serial.println("Time configured!");

  struct tm timeinfo;
  while (!getLocalTime(&timeinfo)) {
    Serial.println("Waiting for NTP...");
    delay(1000);
  }
  char buffer[30];
  strftime(buffer, sizeof(buffer), "%Y-%m-%d %H:%M:%S", &timeinfo);
  Serial.print("Current time: ");
  Serial.println(buffer);
}

void loop() {
  float temp = dht.readTemperature();
  float hum = dht.readHumidity();

  if (isnan(temp) || isnan(hum)) {
    lcd.setCursor(0, 0);
    lcd.print("Sensor error!   ");
    Serial.println("Failed to read DHT sensor!");
    delay(2000);
    return;
  }

  // Update LCD
  lcd.setCursor(0, 0);
  lcd.print("Nhiet do: ");
  lcd.print(temp);
  lcd.print((char)223); // °C
  lcd.print("   ");      // xóa ký tự cũ thừa

  lcd.setCursor(0, 1);
  lcd.print("Do am: ");
  lcd.print(hum);
  lcd.print("%   ");

  // Send to Firebase
  if (WiFi.status() == WL_CONNECTED) {
    WiFiClientSecure client;
    client.setInsecure();
    HTTPClient http;

    String url = FIREBASE_URL + "/sensor_data.json";
    String currentTime = getCurrentTime();
    unsigned long timestamp = time(nullptr);

    String jsonData = "{"
                      "\"temperature\": " + String(temp) +
                      ", \"humidity\": " + String(hum) +
                      ", \"datetime\": \"" + currentTime + "\"" +
                      ", \"timestamp\": " + String(timestamp) +
                      "}";

    Serial.println("[DEBUG] Sending to Firebase:");
    Serial.println(jsonData);

    if (http.begin(client, url)) {
      http.addHeader("Content-Type", "application/json");
      int httpResponseCode = http.POST(jsonData);

      if (httpResponseCode > 0) {
        Serial.print("[OK] Code: ");
        Serial.println(httpResponseCode);
        String payload = http.getString();
        Serial.println(payload);
      } else {
        Serial.print("[ERROR] HTTP POST failed, code: ");
        Serial.println(httpResponseCode);
      }
      http.end();
    } else {
      Serial.println("[ERROR] Cannot connect to Firebase URL");
    }
  } else {
    Serial.println("WiFi disconnected!");
    lcd.setCursor(0, 1);
    lcd.print("WiFi lost...   ");
  }

  delay(5000);
}
