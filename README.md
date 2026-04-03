# UrbanFix

A Flutter mobile application and web dashboard for reporting and tracking civic issues with photo evidence, GPS location, and community engagement.

## 🚀 Quick Start

### Mobile App
```bash
cd mobile_app
flutter pub get
flutter run
```

### Agency Dashboard
Open `agency-dashboard/index.html` in a web browser.

## 📱 Components

- **Mobile App**: Flutter application (Android, iOS, Windows)
- **Agency Dashboard**: Web-based dashboard for agencies to manage reports
- **Backend**: Supabase (Authentication, Database, Storage)

## 🎯 Features

- Report civic issues with camera & GPS
- Google Maps integration
- Community feed with filters
- Upvoting and commenting system
- User profiles & gamification
- Leaderboard
- Real-time updates
- Agency dashboard for issue management

## 📦 Tech Stack

- **Mobile**: Flutter 3.38+
- **Backend**: Supabase
- **State Management**: Provider
- **Maps**: Google Maps Flutter
- **Navigation**: go_router
- **Dashboard**: HTML/CSS/JavaScript

## 🔧 Setup

### 1. Supabase Configuration

Update `mobile_app/lib/config/supabase_config.dart` with your Supabase credentials:
```dart
static const String supabaseUrl = 'YOUR_SUPABASE_URL';
static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
```

Update `agency-dashboard/js/config.js` with the same credentials.

### 2. Database Schema

Run the SQL in `supabase_schema.sql` in your Supabase SQL Editor to create all necessary tables.

### 3. Storage Bucket

Create a public bucket named `report-images` in Supabase Storage with public access.

### 4. Google Maps API (Optional)

Add your API key to `mobile_app/android/app/src/main/AndroidManifest.xml`:
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_GOOGLE_MAPS_API_KEY"/>
```

## 📁 Project Structure

```
UrbanFix - Flutter/
├── mobile_app/              # Flutter mobile application
│   ├── lib/
│   │   ├── config/         # Configuration files
│   │   ├── models/         # Data models
│   │   ├── screens/        # UI screens
│   │   ├── services/       # Business logic & API calls
│   │   └── widgets/        # Reusable widgets
│   └── android/            # Android platform files
├── agency-dashboard/        # Web dashboard for agencies
│   ├── index.html
│   ├── css/
│   └── js/
└── supabase_schema.sql     # Database schema
```

## 🔐 Authentication

The app uses Supabase Authentication with email/password. Users can:
- Sign up with email and password
- Sign in to existing accounts
- Reset passwords
- Maintain session across app restarts

## 📄 License

MIT
