from fastapi import FastAPI
from services.weather_service import WeatherService

app = FastAPI()

# Initialize Service
weather_service = WeatherService()

@app.get("/")
def home():
    return {"message": "API running OK!"}

@app.get("/realtime")
def realtime_forecast():
    return weather_service.get_realtime_forecast()

@app.get("/latest")
def get_latest_record():
    return weather_service.get_latest_record()

@app.get("/stats")
def get_stats():
    return weather_service.get_stats()

@app.get("/health")
def health_check():
    return weather_service.check_health()

@app.get("/alerts")
def get_alerts(temp_high: float = None):
    return weather_service.get_alerts(temp_high_threshold=temp_high)
