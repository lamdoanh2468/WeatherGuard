import requests
from requests.adapters import HTTPAdapter
from urllib3.util.retry import Retry
import sys
import os

# Add parent directory to path to import config
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
import config

class FirebaseService:
    def __init__(self):
        self.session = requests.Session()
        retries = Retry(total=5, backoff_factor=1, status_forcelist=[500, 502, 503, 504])
        self.session.mount("https://", HTTPAdapter(max_retries=retries))

    def fetch_data(self):
        try:
            response = self.session.get(config.FIREBASE_URL, timeout=10)
            response.raise_for_status()
            data = response.json()
            if not data:
                return {}
            return data
        except requests.exceptions.RequestException as e:
            print(f"Error fetching data from Firebase: {e}")
            return {}

    def fetch_sensor_data(self):
        data = self.fetch_data()
        if not data or "sensor_data" not in data:
            return {}
        return data["sensor_data"]

    def check_connection(self):
        try:
            response = self.session.get(config.FIREBASE_URL, timeout=5)
            return response.status_code == 200
        except:
            return False
