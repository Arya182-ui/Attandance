# Firebase Setup Guide

## Step-by-Step Firebase Configuration

### 1. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add Project"
3. Enter project name: "Attendance System"
4. Enable Google Analytics (optional)
5. Click "Create Project"

### 2. Enable Authentication

1. In Firebase Console, go to "Authentication"
2. Click "Get Started"
3. Enable "Email/Password" sign-in method
4. Save

### 3. Create Firestore Database

1. Go to "Firestore Database"
2. Click "Create Database"
3. Select "Start in production mode"
4. Choose a location closest to your users
5. Click "Enable"

### 4. Enable Firebase Storage

1. Go to "Storage"
2. Click "Get Started"
3. Use default security rules for now
4. Click "Done"

### 5. Configure Flutter Apps

#### Install FlutterFire CLI
```bash
npm install -g firebase-tools
dart pub global activate flutterfire_cli
```

#### Login to Firebase
```bash
firebase login
```

#### Configure Student App
```bash
cd student_app
flutterfire configure --project=your-project-id
```

Select:
- ✅ Android
- ✅ iOS
- ✅ Web (optional)

This creates `lib/firebase_options.dart`

#### Configure Admin Panel
```bash
cd ../admin_panel
flutterfire configure --project=your-project-id
```

Select:
- ✅ Web
- ✅ Android (optional)
- ✅ iOS (optional)

### 6. Deploy Security Rules

From project root:
```bash
firebase init firestore
firebase init storage
firebase deploy --only firestore:rules
firebase deploy --only storage
```

### 7. Create Admin User

#### Via Firebase Console:
1. Go to Authentication
2. Add User: email=`admin@yourdomain.com`, password=`yourpassword`
3. Copy the User UID
4. Go to Firestore
5. Create collection: `users`
6. Add document with the User UID:
   ```json
   {
     "name": "Admin Name",
     "email": "admin@yourdomain.com",
     "role": "admin"
   }
   ```

### 8. Initialize Institute Settings

#### Via Firebase Console:
1. Go to Firestore
2. Create collection: `institute`
3. Add document with ID: `settings`
   ```json
   {
     "latitude": 0.0,
     "longitude": 0.0,
     "radius": 100.0
   }
   ```

### 9. Platform-Specific Setup

#### Android (Student App)

Add to `student_app/android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.INTERNET" />
```

#### iOS (Student App)

Add to `student_app/ios/Runner/Info.plist`:
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location to verify attendance at the institute</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>We need your location to verify attendance</string>
```

### 10. Test the Setup

#### Test Student App:
1. Run the app
2. Try to login (should fail - no students yet)

#### Test Admin Panel:
1. Run on web browser
2. Login with admin credentials
3. Add a test student
4. Set institute location in settings

#### Test Complete Flow:
1. Login to student app with test student
2. Go to institute location (or adjust radius)
3. Try check-in
4. Verify attendance appears in admin panel

## Troubleshooting

### Firebase Connection Issues
- Check internet connection
- Verify `google-services.json` and `GoogleService-Info.plist` are in correct locations
- Rebuild the app after adding Firebase config files

### Location Permission Denied
- Check OS settings for app permissions
- Ensure manifest/plist entries are correct
- Request permissions at runtime

### Firestore Permission Denied
- Verify security rules are deployed
- Check user authentication status
- Ensure user document has correct role field

### Admin Can't Login
- Verify user exists in Authentication
- Check user document exists in Firestore with role="admin"
- Check email/password are correct

## Production Checklist

- [ ] Enable App Check for security
- [ ] Set up proper API key restrictions
- [ ] Configure Firebase project budget alerts
- [ ] Set up Cloud Functions for advanced features
- [ ] Enable Firebase Analytics
- [ ] Set up Crashlytics
- [ ] Configure backup for Firestore
- [ ] Review and tighten security rules
- [ ] Set up monitoring and alerts
- [ ] Test thoroughly on production environment
