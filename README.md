# Geo-Fenced Attendance System

Geo-fenced attendance platform with:
- `student_app`: Flutter app used by students for check-in/check-out.
- `admin-web`: React + TypeScript web panel for admins.
- Firebase backend: Authentication, Firestore, Storage, and security rules.

## What It Does

- Role-based access for students and admins
- Geo-fenced attendance check-in using device location
- Check-out and attendance history tracking
- Admin student management (create, update, delete)
- Institute location/radius configuration
- Attendance filtering and CSV export

## Repository Structure

```text
Attandance/
  admin-web/            # React + TypeScript admin panel (Vite)
  student_app/          # Flutter student app
  firestore.rules       # Firestore security rules
  firebase.json         # Firebase deploy config
```

## Tech Stack

- Student app: Flutter, Riverpod, Firebase SDKs, Geolocator
- Admin panel: React 18, TypeScript, Vite, Zustand, React Query, Firebase JS SDK
- Backend: Firebase Authentication, Cloud Firestore, Firebase Storage

## Prerequisites

- Flutter SDK (3.x)
- Node.js (16+)
- Firebase CLI
- FlutterFire CLI (for Flutter app configuration)
- A Firebase project

## Quick Start

1. Clone and open the repository:

```bash
git clone https://github.com/Arya182-ui/Attandance.git
cd Attandance
```

2. Configure Firebase for `student_app`:

```bash
cd student_app
flutterfire configure --project=YOUR_FIREBASE_PROJECT_ID
```

3. Install dependencies:

```bash
# Student app
cd student_app
flutter pub get

# Admin panel
cd ../admin-web
npm install
```

4. Deploy security rules from repository root:

```bash
firebase deploy --only firestore:rules
```

5. Create first admin user:
- Create user in Firebase Authentication.
- In Firestore `users` collection, create document with Auth UID as document id:

```json
{
  "email": "admin@example.com",
  "name": "Admin Name",
  "role": "admin"
}
```

6. Configure institute settings in admin panel after first login:
- latitude
- longitude
- allowed radius (meters)

## Run Locally

Student app:

```bash
cd student_app
flutter run
```

Admin panel:

```bash
cd admin-web
npm run dev
```

## Build for Production

Student app example:

```bash
cd student_app
flutter build apk --release
```

Admin panel:

```bash
cd admin-web
npm run build
```

## Firestore Collections (High Level)

- `users`: profile + role (`student`/`admin`)
- `institute`: geo-fence settings (latitude, longitude, radius)
- `attendance`: per-student daily attendance records

## Documentation Index

- `FIREBASE_SETUP.md`: detailed Firebase setup
- `ARCHITECTURE.md`: codebase and data flow architecture
- `FEATURES.md`: complete feature list
- `CONTRIBUTING.md`: contribution workflow and standards
- `MOBILE_UX_IMPROVEMENTS.md`: student app UX updates
- `CHANGELOG.md`: release history

## License

MIT License. See `LICENSE`.
