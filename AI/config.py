import os

# Firebase Configuration
FIREBASE_URL = "https://dht11anddht22-14fb9-default-rtdb.asia-southeast1.firebasedatabase.app/.json"

# Alert Thresholds
TEMP_HIGH_DANGER = 37
TEMP_HIGH_WARN = 33
TEMP_LOW_WARN = 26

HUM_HIGH_WARN = 80
HUM_LOW_WARN = 20

# Paths
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
MODEL_DIR = os.path.join(BASE_DIR, "models_comparison")
