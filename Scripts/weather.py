import requests
import geopandas as gpd
from shapely.geometry import Point
import numpy as np
from dataclasses import dataclass
from typing import List, Dict, Optional
from datetime import datetime
import json, os

# =========================
# MODELS
# =========================

@dataclass
class CurrentWeather:
    temperature: float
    windspeed: float
    winddirection: int
    weathercode: int
    time: str
    interval: int
    is_day: int


@dataclass
class DailyForecast:
    date: datetime
    temp_max: float
    temp_min: float
    precipitation_sum: float
    wind_speed_max: float
    wind_direction: int
    weathercode: int
    sunrise: str
    sunset: str


@dataclass
class WeatherResult:
    city: str
    country: str
    latitude: float
    longitude: float
    current: CurrentWeather
    forecast: List[DailyForecast]


# =========================
# CLIENT
# =========================

class OpenMeteoClient:
    GEO_URL = "https://geocoding-api.open-meteo.com/v1/search"
    WEATHER_URL = "https://api.open-meteo.com/v1/forecast"

    # -------------------------
    # GEO
    # -------------------------
    def get_coordinates(self, city: str, country: Optional[str] = None):
        params = {
            "name": city,
            "count": 5,
            "language": "en",
            "format": "json"
        }

        r = requests.get(self.GEO_URL, params=params)
        r.raise_for_status()
        data = r.json()

        if "results" not in data:
            raise ValueError(f"City not found: {city}")

        results = data["results"]

        if country:
            results = [x for x in results if x["country"].lower() == country.lower()]
            if not results:
                raise ValueError(f"No match found for {city} in {country}")

        best = results[0]

        return {
            "name": best["name"],
            "country": best["country"],
            "latitude": best["latitude"],
            "longitude": best["longitude"]
        }

    # -------------------------
    # BASIC WEATHER
    # -------------------------
    def get_weather(self, lat: float, lon: float):
        params = {
            "latitude": lat,
            "longitude": lon,
            "current_weather": True,
            "daily": [
                "temperature_2m_max",
                "temperature_2m_min",
                "precipitation_sum",
                "wind_speed_10m_max",
                "wind_direction_10m_dominant",
                "weathercode",
                "sunrise",
                "sunset"
            ],
            "timezone": "auto"
        }

        r = requests.get(self.WEATHER_URL, params=params)
        r.raise_for_status()
        return r.json()

    def get_weather_by_city(self, city: str, country: Optional[str] = None) -> WeatherResult:
        loc = self.get_coordinates(city, country)
        data = self.get_weather(loc["latitude"], loc["longitude"])

        current = data["current_weather"]
        daily = data["daily"]

        forecast = [
            DailyForecast(
                date=datetime.strptime(daily["time"][i], "%Y-%m-%d"),
                temp_max=daily["temperature_2m_max"][i],
                temp_min=daily["temperature_2m_min"][i],
                precipitation_sum=daily["precipitation_sum"][i],
                wind_speed_max=daily["wind_speed_10m_max"][i],
                wind_direction=daily["wind_direction_10m_dominant"][i],
                weathercode=daily["weathercode"][i],
                sunrise=daily["sunrise"][i],
                sunset=daily["sunset"][i],
            )
            for i in range(len(daily["time"]))
        ]

        return WeatherResult(
            city=loc["name"],
            country=loc["country"],
            latitude=loc["latitude"],
            longitude=loc["longitude"],
            current=CurrentWeather(**current),
            forecast=forecast
        )

    # -------------------------
    # FRANCE GRID
    # -------------------------
    def _generate_france_grid(self, step: float):
        url = "https://raw.githubusercontent.com/gregoiredavid/france-geojson/master/regions.geojson"
        regions = gpd.read_file(url).to_crs("EPSG:4326")

        lats = np.arange(41.3, 51.2, step)
        lons = np.arange(-5.0, 9.6, step)

        lon_grid, lat_grid = np.meshgrid(lons, lats)

        gdf = gpd.GeoDataFrame(
            {'lat': lat_grid.flatten(), 'lon': lon_grid.flatten()},
            geometry=[Point(xy) for xy in zip(lon_grid.flatten(), lat_grid.flatten())],
            crs="EPSG:4326"
        )

        points = gpd.sjoin(gdf, regions[['nom', 'geometry']], predicate='within')

        return regions, points

    # -------------------------
    # BATCH FETCH
    # -------------------------
    def _fetch_batch(self, coords):
        all_data = []

        for i in range(0, len(coords), 50):
            batch = coords[i:i+50]

            params = {
                "latitude": ",".join(str(p[0]) for p in batch),
                "longitude": ",".join(str(p[1]) for p in batch),
                "daily": "temperature_2m_max,temperature_2m_min,precipitation_sum,weathercode,wind_speed_10m_max",
                "timezone": "auto"
            }

            r = requests.get(self.WEATHER_URL, params=params)

            try:
                data = r.json()
            except:
                print("JSON error")
                continue

            # IMPORTANT DEBUG
            if "error" in data:
                print("API ERROR:", data)
                continue

            if isinstance(data, list):
                all_data.extend(data)
            else:
                all_data.append(data)

        # DEBUG
        print(f"Total API responses: {len(all_data)}")

        valid = [d for d in all_data if isinstance(d, dict) and "daily" in d]

        print(f"Valid responses: {len(valid)}")

        return valid

    # -------------------------
    # NATIONAL WEEKLY FORECAST
    # -------------------------
    def get_national_weekly_forecast(self) -> List[Dict]:
        url = "https://raw.githubusercontent.com/gregoiredavid/france-geojson/master/regions.geojson"
        regions = gpd.read_file(url).to_crs("EPSG:4326")

        def sample_points(polygon, n=3):
            minx, miny, maxx, maxy = polygon.bounds
            points = []

            while len(points) < n:
                p = Point(
                    np.random.uniform(minx, maxx),
                    np.random.uniform(miny, maxy)
                )
                if polygon.contains(p):
                    points.append(p)

            return points

        # 1. Generate 3 points per region
        region_points = []

        for _, row in regions.iterrows():
            pts = sample_points(row.geometry, 3)
            for p in pts:
                region_points.append({
                    "region": row["nom"],
                    "lat": p.y,
                    "lon": p.x
                })

        # 2. API request (single batch)
        coords = [(p["lat"], p["lon"]) for p in region_points]

        params = {
            "latitude": ",".join(str(p[0]) for p in coords),
            "longitude": ",".join(str(p[1]) for p in coords),
            "daily": "temperature_2m_max,temperature_2m_min,precipitation_sum,weathercode,wind_speed_10m_max",
            "timezone": "auto"
        }

        r = requests.get(self.WEATHER_URL, params=params)
        data = r.json()

        if "error" in data:
            raise ValueError(f"API error: {data}")

        responses = data if isinstance(data, list) else [data]

        results = []

        for day_idx in range(7):

            try:
                date = responses[0]["daily"]["time"][day_idx]
            except:
                break

            reg_summary = {}

            for region in regions["nom"].unique():

                vals = []

                for i, pt in enumerate(region_points):
                    if pt["region"] != region:
                        continue

                    try:
                        d = responses[i]["daily"]

                        vals.append({
                            "tmax": d["temperature_2m_max"][day_idx],
                            "tmin": d["temperature_2m_min"][day_idx],
                            "rain": d["precipitation_sum"][day_idx],
                            "wind": d["wind_speed_10m_max"][day_idx],
                            "code": d["weathercode"][day_idx]
                        })
                    except:
                        continue

                if not vals:
                    continue

                reg_summary[region] = {
                    "t_max": round(np.mean([v["tmax"] for v in vals])),
                    "t_min": round(np.mean([v["tmin"] for v in vals])),
                    "rain": round(np.mean([v["rain"] for v in vals])),
                    "wind": round(np.max([v["wind"] for v in vals])),
                    "weathercode": round(np.mean([v["code"] for v in vals]))
                }

            # National stats
            all_tmax = [
                responses[i]["daily"]["temperature_2m_max"][day_idx]
                for i in range(len(responses))
                if len(responses[i]["daily"]["temperature_2m_max"]) > day_idx
            ]

            all_tmin = [
                responses[i]["daily"]["temperature_2m_min"][day_idx]
                for i in range(len(responses))
                if len(responses[i]["daily"]["temperature_2m_min"]) > day_idx
            ]

            results.append({
                "date": date,
                "regions": reg_summary,
                "avg_max": round(np.mean(all_tmax)) if all_tmax else None,
                "avg_min": round(np.mean(all_tmin)) if all_tmin else None,
                "max_abs": max(all_tmax) if all_tmax else None,
                "min_abs": min(all_tmin) if all_tmin else None
            })

        return results

    def get_national_today_forecast(self) -> Dict:
        weekly = self.get_national_weekly_forecast()

        if not weekly:
            raise ValueError("No data available")

        return weekly[0]

    def get_national_tomorrow_forecast(self) -> Dict:
        weekly = self.get_national_weekly_forecast()

        if len(weekly) < 2:
            raise ValueError("Not enough data for tomorrow")

        return weekly[1]


def weather_code_to_text(code):
    if (code == 0):
      return 10
    if (code == 1):
      return 10
    if (code == 2):
      return 0
    if (code == 3):
      return 0
    if (code == 45 or code == 48):
      return 4
    if (code >= 51 and code <= 67):
      return 7
    if (code >= 71 and code <= 77):
      return 8
    if (code >= 80 and code <= 82):
      return 7
    if (code >= 95 and code <= 99):
      return 6
    return 10


# =========================
# MAIN
# =========================

dirname = os.path.dirname(__file__)
jsonFile = os.path.join(dirname, '../Config/weather.json')

with open(jsonFile, 'r') as file:
    data = json.load(file)
    

client = OpenMeteoClient()
w = client.get_weather_by_city(data["city"], data["country"])

m_date = datetime.now()
data["last-update"] = f"{m_date.strftime('%Y-%m-%d %H:%M')}"

currentTemperature = w.current.temperature
currentConditions = weather_code_to_text(w.current.weathercode)
currentIsDay = w.current.is_day

data["current"] = {
    "temperature": currentTemperature,
    "contitions": currentConditions,
    "is_day": currentIsDay
}

forecasts = []
for f in range(len(w.forecast)):
    date = w.forecast[f].date
    temp_max = w.forecast[f].temp_max
    temp_min = w.forecast[f].temp_min
    precipitation_sum = w.forecast[f].precipitation_sum
    wind_speed_max = w.forecast[f].wind_speed_max
    weathercode = weather_code_to_text(w.forecast[f].weathercode)
    forecasts.append({
        "date": f"{date}",
        "temp_max": temp_max,
        "temp_min": temp_min,
        "precipitation_sum": precipitation_sum,
        "wind_speed_max": wind_speed_max,
        "weathercode": weathercode
    })

data["forecast"] = forecasts

with open(jsonFile, 'w', encoding='utf-8') as f:
    json.dump(data, f, indent=4)