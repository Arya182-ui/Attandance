# Firebase Setup Guide

This guide configures Firebase for both apps in this repository:
- `student_app` (Flutter)
- `admin-web` (React + TypeScript)

## 1. Create Firebase Project

1. Open Firebase Console.
2. Create a new project.
3. Enable these products:
   - Authentication (Email/Password)
   - Cloud Firestore
   - Firebase Storage

## 2. Register Applications

Register the platforms you need:

- Flutter app (`student_app`): Android/iOS/Web as needed
- Web app (`admin-web`): Web

## 3. Configure `student_app`

Install tooling:

```bash
npm install -g firebase-tools
dart pub global activate flutterfire_cli
firebase login
```

Generate Flutter Firebase options:

```bash
cd student_app
flutterfire configure --project=YOUR_FIREBASE_PROJECT_ID
```

This generates `student_app/lib/firebase_options.dart`.

## 4. Configure `admin-web`

`admin-web` uses Firebase Web config in code. Update values in:

- `admin-web/src/services/firebase.ts`

Use the Firebase Console web app config values (`apiKey`, `authDomain`, `projectId`, etc.).

## 5. Deploy Firestore Rules

From repository root:

```bash
firebase deploy --only firestore:rules
```

## 6. Seed Initial Admin User

1. Create an auth user in Firebase Authentication.
2. Copy the user UID.
3. In Firestore `users` collection, create document with the same UID.

Example document:

```json
{
  "name": "Admin Name",
  "email": "admin@example.com",
  "role": "admin"
}
```

## 7. Seed Institute Settings

Create `institute/settings` document:

```json
{
  "latitude": 0.0,
  "longitude": 0.0,
  "radius": 100.0
}
```

## 8. Student App Platform Notes

Android permissions (in `AndroidManifest.xml`):

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.INTERNET" />
```

iOS permissions (in `Info.plist`):

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Location is required to validate attendance check-in.</string>
```

## 9. Verification Checklist

- Admin can sign in to `admin-web`.
- Admin can add a student.
- Student can sign in on `student_app`.
- Student can check in only within configured radius.
- Attendance appears in admin panel.

## Troubleshooting

### Firestore `permission-denied`

- Confirm user is authenticated.
- Confirm `users/{uid}` exists with correct `role`.
- Confirm latest rules are deployed.

### Admin login blocked

- Confirm auth user exists.
- Confirm matching Firestore user document exists.
- Confirm role is exactly `admin`.

### Student app Firebase init errors

- Re-run `flutterfire configure`.
- Confirm `student_app/lib/firebase_options.dart` exists.
- Rebuild after config updates.

## Production Hardening

- Enable App Check where applicable.
- Restrict API keys by platform/domain.
- Configure budget alerts and monitoring.
- Review and tighten Firestore rules.
