# Geo-Fenced Attendance System

A complete production-ready attendance management system built with **Flutter** and **Firebase** that uses geolocation to ensure students can only check-in when they are within a specified radius of the institute.

## 🎯 Features

### Student Mobile App
- ✅ Email/Password Authentication
- ✅ Role-based access (Students only)
- ✅ Geo-fenced Check-in/Check-out
- ✅ Real-time location validation
- ✅ Attendance history viewing
- ✅ Prevents multiple check-ins per day
- ✅ Clean and intuitive UI

### Admin Web Panel
- ✅ Admin authentication
- ✅ Student management (CRUD operations)
- ✅ Institute location settings
- ✅ Radius configuration
- ✅ Attendance viewing with filters
- ✅ CSV export functionality
- ✅ Responsive web design

## 🏗️ Architecture

This project follows **Clean Architecture** principles:

```
├── domain/           # Business logic layer
│   ├── entities/     # Core business objects
│   ├── repositories/ # Abstract repository interfaces
│   └── usecases/     # Business logic use cases
├── data/             # Data layer
│   ├── datasources/  # Firebase data sources
│   ├── models/       # Data models with serialization
│   └── repositories/ # Repository implementations
└── presentation/     # UI layer
    ├── providers/    # Riverpod state management
    ├── screens/      # UI screens
    └── widgets/      # Reusable widgets
```

## 🛠️ Tech Stack

- **Frontend:** Flutter 3.x
- **State Management:** Riverpod
- **Backend:** Firebase
  - Firebase Authentication
  - Cloud Firestore
  - Firebase Storage
- **Geolocation:** Geolocator package
- **CSV Export:** csv package

## 📋 Prerequisites

Before you begin, ensure you have:

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (3.0 or higher)
- [Firebase CLI](https://firebase.google.com/docs/cli)
- [FlutterFire CLI](https://firebase.flutter.dev/docs/cli/)
- A Firebase project
- Android Studio / VS Code with Flutter extensions

## 🚀 Setup Instructions

### 1. Clone the Repository

```bash
git clone https://github.com/Arya182-ui/Attandance.git
cd Attandance
```

### 2. Firebase Setup

#### Create a Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project
3. Enable Authentication (Email/Password)
4. Enable Cloud Firestore
5. Enable Firebase Storage

#### Configure Firebase for Flutter

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase for Student App
cd student_app
flutterfire configure

# Configure Firebase for Admin Panel
cd ../admin_panel
flutterfire configure
```

This will generate `firebase_options.dart` files in both projects.

### 3. Deploy Firestore Security Rules

```bash
# From the root directory
firebase deploy --only firestore:rules
firebase deploy --only storage
```

### 4. Install Dependencies

#### Student App
```bash
cd student_app
flutter pub get
```

#### Admin Panel
```bash
cd ../admin_panel
flutter pub get
```

### 5. Create Initial Admin User

You need to manually create the first admin user in Firebase Console:

1. Go to Firebase Console > Authentication
2. Add a new user with email and password
3. Go to Cloud Firestore
4. Create a document in the `users` collection:
   ```json
   {
     "email": "admin@example.com",
     "name": "Admin Name",
     "role": "admin"
   }
   ```
   Use the Auth UID as the document ID.

### 6. Set Institute Settings

After logging in as admin for the first time:
1. Go to Institute Settings
2. Set your institute's latitude and longitude
3. Set the allowed radius (in meters)

You can find coordinates using [Google Maps](https://www.google.com/maps) - right-click on a location and copy the coordinates.

## 📱 Running the Applications

### Student Mobile App

```bash
cd student_app

# For Android
flutter run

# For iOS
flutter run

# For Web (not recommended for mobile app)
flutter run -d chrome
```

### Admin Web Panel

```bash
cd admin_panel

# Run on Chrome
flutter run -d chrome

# Build for production
flutter build web
```

## 🗂️ Firestore Database Structure

### Collections

#### `users`
```json
{
  "id": "auto-generated",
  "name": "John Doe",
  "email": "student@example.com",
  "role": "student" // or "admin"
}
```

#### `institute`
```json
{
  "settings": {
    "latitude": 40.7128,
    "longitude": -74.0060,
    "radius": 100.0
  }
}
```

#### `attendance`
```json
{
  "id": "studentId_YYYY-MM-DD",
  "studentId": "userId",
  "date": "Timestamp",
  "checkInTime": "Timestamp",
  "checkOutTime": "Timestamp",
  "checkInLocation": {
    "latitude": 40.7128,
    "longitude": -74.0060
  },
  "checkOutLocation": {
    "latitude": 40.7128,
    "longitude": -74.0060
  },
  "status": "checked_in", // or "checked_out", "absent"
  "createdAt": "Server Timestamp"
}
```

## 🔐 Security Rules

The project includes comprehensive Firestore security rules:

- ✅ Students can only read their own data
- ✅ Students cannot modify institute settings
- ✅ Admins have full access
- ✅ Attendance records are protected by role-based access
- ✅ Prevents duplicate check-ins on the same day

## 📊 Business Logic

### Check-in Process
1. Student requests location permission
2. App gets current GPS coordinates
3. Fetches institute settings from Firestore
4. Calculates distance using Haversine formula
5. If distance ≤ allowed radius → Allow check-in
6. If distance > allowed radius → Show error
7. Prevents multiple check-ins on same day

### Check-out Process
1. Gets current GPS coordinates
2. Updates existing attendance record
3. Records check-out time and location

## 🧪 Testing

### Test Student Account
Create a test student in Firebase:
1. Authentication: Add user with email/password
2. Firestore: Add user document with role="student"

### Test Location
For testing, you can temporarily:
1. Use device location simulator in Android Studio/Xcode
2. Or modify the radius to a larger value
3. Or use actual GPS coordinates of your test location

## 📦 Dependencies

### Student App
- `flutter_riverpod`: State management
- `firebase_core`, `firebase_auth`, `cloud_firestore`: Firebase integration
- `geolocator`: Location services
- `permission_handler`: Permissions
- `intl`: Date formatting

### Admin Panel
- `flutter_riverpod`: State management
- `firebase_core`, `firebase_auth`, `cloud_firestore`: Firebase integration
- `csv`: CSV export
- `universal_html`: Web downloads
- `intl`: Date formatting

## 🎨 Features in Detail

### Geofencing
- Uses Haversine formula for accurate distance calculation
- Validates student location before allowing check-in
- Configurable radius from admin panel

### State Management
- Clean Riverpod architecture
- Separation of concerns
- Reactive UI updates

### Error Handling
- Comprehensive error messages
- Location permission handling
- Network error handling

## 🚧 Troubleshooting

### Location Permission Issues (Android)
Add to `AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

### Location Permission Issues (iOS)
Add to `Info.plist`:
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs location access to verify attendance</string>
```

### Firebase Configuration
If you get Firebase errors, ensure:
1. `google-services.json` (Android) is in `android/app/`
2. `GoogleService-Info.plist` (iOS) is in `ios/Runner/`
3. `firebase_options.dart` is properly generated

## 📝 License

This project is open-source and available under the MIT License.

## 👨‍💻 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📧 Support

For issues and questions, please open an issue in the GitHub repository.

---

**Built with ❤️ using Flutter and Firebase**
