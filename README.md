# Count My Days - Lifespan Visualizer & Tracker

A minimalistic cross-platform app that helps you visualize your lifespan through a daily grid format. Track your life journey one day at a time.

## Features

- **Birthdate Input**: Set your birthdate with validation (no future dates)
- **Lifespan Grid**: Visual grid showing days/weeks/months of your life
- **Multiple View Modes**: Daily, Weekly, or Monthly views
- **Statistics Dashboard**: Days lived, days remaining, life progress percentage
- **Automatic/Manual Modes**: Auto-fill past days or manually check them
- **Customizable Lifespan**: Default 70 years, adjustable up to 150 years
- **100% Offline**: All data stored locally, no internet required
- **Cross-Platform**: Single codebase for Android and Windows

## Tech Stack

- **Framework**: Flutter (Dart)
- **Storage**: SharedPreferences (local storage)
- **Platform Support**: Android (.apk) and Windows (.exe)

## Prerequisites

1. Install Flutter SDK (3.0 or higher)
2. Install Android Studio with Android SDK
3. For Windows builds: Visual Studio 2022 with Desktop development with C++

## Setup Instructions

1. Clone this repository
2. Navigate to the project directory
3. Install dependencies:
   ```bash
   flutter pub get
   ```

## Build Instructions

### Android APK

```bash
# For debug APK
flutter build apk --debug

# For release APK (smaller size, optimized)
flutter build apk --release

# For split APKs by ABI (smaller downloads)
flutter build apk --split-per-abi
```

The APK files will be in:
- Debug: `build/app/outputs/flutter-apk/app-debug.apk`
- Release: `build/app/outputs/flutter-apk/app-release.apk`

### Windows EXE

```bash
# For debug build
flutter build windows --debug

# For release build (optimized)
flutter build windows --release
```

The Windows executable will be in:
- `build/windows/runner/Release/count_my_days.exe`

To create a standalone package, copy the entire `Release` folder which includes:
- `count_my_days.exe`
- Required DLL files
- `data` folder with Flutter assets

## Running the App

### Development Mode

```bash
# List available devices
flutter devices

# Run on connected device
flutter run

# Run on specific device
flutter run -d windows
flutter run -d <android-device-id>
```

### Testing on Different Screen Sizes

```bash
# Run with device preview
flutter run --dart-define=FLUTTER_DEVICE_PREVIEW=true
```

## Project Structure

```
count_my_days/
├── lib/
│   └── main.dart          # Main application code
├── pubspec.yaml           # Project dependencies
├── android/               # Android-specific files
├── windows/               # Windows-specific files
└── build/                 # Build outputs
```

## Key Components

1. **HomePage**: Main screen with navigation
2. **Statistics Card**: Shows days lived, remaining, and progress
3. **Lifespan Grid**: Interactive grid visualization
4. **Settings Panel**: Configure view modes and preferences

## Performance Optimization

- Grid uses `GridView.builder` for efficient rendering of 25,000+ cells
- Lazy loading ensures smooth scrolling
- Minimal state updates for better performance
- Responsive cell sizing based on screen dimensions

## Local Storage

Data stored using SharedPreferences:
- Birthdate (timestamp)
- Lifespan years
- View mode preference
- Auto/manual mode setting
- Manually checked days (for manual mode)
- Notification preferences

## Future Enhancements

While not included in the current version, potential improvements could include:
- iOS support (requires macOS for building)
- Data export functionality
- Multiple profiles
- Theming customization
- Localization support

## Troubleshooting

### Android Build Issues
- Ensure Android SDK is properly installed
- Check `minSdkVersion` in `android/app/build.gradle` (should be 21+)

### Windows Build Issues
- Install Visual Studio with C++ desktop development
- Ensure Windows SDK is installed
- Run `flutter doctor` to check setup

### Performance Issues
- For older devices, consider reducing grid density
- Enable release mode for better performance

## License

This project is provided as-is for personal use.