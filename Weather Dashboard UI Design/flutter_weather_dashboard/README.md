# Flutter Weather Dashboard

Flutter port of the "Weather Dashboard UI Design" React project.

## Requirements
- Flutter SDK (3.22+ recommended)
- Dart SDK (bundled with Flutter)
- An editor (VS Code or Android Studio)

## First-time setup (Windows PowerShell)
```powershell
# 1) Verify Flutter is installed (install from https://flutter.dev if needed)
flutter --version

# 2) Go to the Flutter project directory
cd .\flutter_weather_dashboard

# 3) Create platform folders (android/ios/windows/web) for this project
flutter create .

# 4) Get packages
flutter pub get

# 5) (Optional) Enable Windows desktop target
flutter config --enable-windows-desktop

# 6) See available devices/targets
flutter devices

# 7) Run the app
flutter run
```

## Configure API keys
This app supports OpenWeatherMap and AQICN. For local development, you can either:

- Enter keys via the in-app "Cài đặt API" screen, which stores them securely using Shared Preferences.
- Or create a `.env` file (optional) at the project root (you can copy `.env.example`):

```
OPENWEATHER_API_KEY=your_openweather_key
AQICN_API_KEY=your_aqicn_key
```

> In production, store keys on a backend service.

## Platform permissions (Location – Maps page)
To use current location, add permissions:

### Android – `android/app/src/main/AndroidManifest.xml`
Place these lines inside the `<manifest>` but outside `<application>`:

```xml
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
```

Minimum example inside `<application>` to ensure correct embedding (added by `flutter create .`):

```xml
<application
		android:label="flutter_weather_dashboard"
		android:name="io.flutter.app.FlutterApplication"
		android:icon="@mipmap/ic_launcher">
		<!-- Flutter config here -->
	</application>
```

### iOS – `ios/Runner/Info.plist`
Add these keys:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Ứng dụng cần quyền vị trí để hiển thị dữ liệu theo vị trí của bạn.</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>Ứng dụng cần quyền vị trí để hiển thị dữ liệu theo vị trí của bạn.</string>
```

On iOS 13+, location permission requests occur at runtime.

## Structure
- `lib/services/weather_service.dart` – HTTP client with mock fallbacks.
- `lib/providers/weather_provider.dart` – App state with Provider.
- `lib/models/weather_models.dart` – Data models shared across app.
- `lib/pages/*` – UI screens mirroring the React app: Dashboard, Charts, Maps, Alerts, Account, API Key Setup.

## Notes
- Location permissions are requested at runtime for Maps/Current location.
- Some pages include placeholder UI to be iterated later.

## Troubleshooting
- If `flutter` is not recognized in PowerShell, install Flutter and add it to PATH, then reopen the terminal.
- If Android build fails, ensure Android SDK and an emulator or device are set up in Android Studio.
- If Windows desktop build fails, run `flutter doctor` and install the required Visual Studio Desktop development components.
