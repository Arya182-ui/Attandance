# Quick Start Guide

Get your Geo-Fenced Attendance System up and running in 30 minutes!

## Prerequisites

- Flutter installed (3.0+)
- Firebase account
- Android Studio or VS Code
- Git

## Step-by-Step Setup

### 1. Clone and Setup (5 minutes)

```bash
# Clone repository
git clone https://github.com/Arya182-ui/Attandance.git
cd Attandance

# Install Firebase CLI
npm install -g firebase-tools
dart pub global activate flutterfire_cli

# Login to Firebase
firebase login
```

### 2. Create Firebase Project (5 minutes)

1. Go to https://console.firebase.google.com/
2. Create new project: "Attendance System"
3. Enable Authentication → Email/Password
4. Enable Firestore Database → Production mode
5. Enable Storage

### 3. Configure Student App (5 minutes)

```bash
cd student_app
flutter pub get
flutterfire configure
# Select your Firebase project
# Enable Android, iOS, Web
```

### 4. Configure Admin Panel (5 minutes)

```bash
cd ../admin_panel
flutter pub get
flutterfire configure
# Select same Firebase project
# Enable Web (primary), Android, iOS (optional)
```

### 5. Deploy Security Rules (2 minutes)

```bash
cd ..
firebase init firestore
# Use existing files: firestore.rules
firebase deploy --only firestore:rules,storage
```

### 6. Create Admin User (3 minutes)

**In Firebase Console:**
1. Authentication → Add User
   - Email: admin@yourdomain.com
   - Password: YourSecurePassword123

2. Firestore → users collection → Add Document
   - Document ID: [use the UID from Authentication]
   - Fields:
     ```
     name: "Admin Name"
     email: "admin@yourdomain.com"
     role: "admin"
     ```

### 7. Test Admin Panel (2 minutes)

```bash
cd admin_panel
flutter run -d chrome
```

Login with admin credentials.

### 8. Setup Institute Settings (2 minutes)

In Admin Panel:
1. Go to "Institute Settings"
2. Enter your institute's GPS coordinates
   - Use Google Maps to find: Right-click → Copy coordinates
   - Latitude: e.g., 40.7128
   - Longitude: e.g., -74.0060
3. Set radius: e.g., 100 (meters)
4. Click "Save Settings"

### 9. Add Test Student (1 minute)

In Admin Panel:
1. Go to "Students"
2. Click "Add Student"
3. Fill in:
   - Name: Test Student
   - Email: student@test.com
   - Password: Test123456
4. Click "Add"

### 10. Test Student App (5 minutes)

```bash
cd ../student_app
flutter run
# Or for web testing:
flutter run -d chrome
```

**Test the flow:**
1. Login with student credentials
2. Click "Check In"
   - If outside radius: You'll see error with distance
   - If inside radius: Check-in succeeds
3. View attendance history

## Testing Tips

### Testing Location Without Being at Institute

**Option 1: Increase Radius**
- Set radius to 10000 meters (10km) in admin panel
- Check-in should work from anywhere nearby

**Option 2: Use Emulator Location**
- Android Studio: Tools → AVD Manager → Extended Controls → Location
- Set GPS coordinates to institute location

**Option 3: Use Web with Mock Location**
- Chrome DevTools → Sensors → Location
- Override coordinates

### Common Issues

**"Location services disabled"**
- Enable GPS on device
- Grant location permission when prompted

**"Only admins can access"**
- Check user role in Firestore is exactly "admin"

**"Only students can access"**
- Check user role in Firestore is exactly "student"

**"Firebase not initialized"**
- Ensure firebase_options.dart exists
- Rebuild app: flutter clean && flutter run

## Next Steps

### For Production

1. **Deploy Admin Panel**
   ```bash
   cd admin_panel
   flutter build web
   firebase hosting:deploy
   ```

2. **Build Student App**
   ```bash
   cd student_app
   # For Android
   flutter build apk --release
   # For iOS
   flutter build ios --release
   ```

3. **Configure Real Institute Location**
   - Update institute settings with actual coordinates
   - Set appropriate radius (50-200 meters typical)

4. **Add Real Students**
   - Use admin panel to add students
   - Distribute credentials securely

### Customization

Want to customize? Check these files:

**Colors/Theme:**
- `student_app/lib/main.dart` - Theme configuration
- `admin_panel/lib/main.dart` - Theme configuration

**Business Rules:**
- `student_app/lib/domain/usecases/check_in_usecase.dart` - Check-in logic
- Modify radius validation, time restrictions, etc.

**UI:**
- `student_app/lib/presentation/screens/` - All UI screens
- `admin_panel/lib/presentation/screens/` - Admin screens

## Getting Help

**Documentation:**
- 📖 [Complete README](README.md)
- 🏗️ [Architecture Guide](ARCHITECTURE.md)
- 🔥 [Firebase Setup](FIREBASE_SETUP.md)
- 🚀 [Deployment Guide](DEPLOYMENT.md)
- ✨ [Features List](FEATURES.md)

**Issues:**
- Check Firebase Console for errors
- Review Firestore security rules
- Verify user roles in database
- Check device location settings

**Community:**
- Open an issue on GitHub
- Check existing issues for solutions

## Success Checklist

- [ ] Firebase project created
- [ ] Student app runs successfully
- [ ] Admin panel runs successfully
- [ ] Admin user created and can login
- [ ] Institute location configured
- [ ] Test student created
- [ ] Student can login
- [ ] Check-in works (with appropriate location/radius)
- [ ] Attendance shows in admin panel
- [ ] CSV export works

**Congratulations! 🎉 Your attendance system is ready!**

---

**Quick Commands Reference**

```bash
# Run student app
cd student_app && flutter run

# Run admin panel (web)
cd admin_panel && flutter run -d chrome

# Deploy admin panel
cd admin_panel && flutter build web && firebase deploy

# Build student APK
cd student_app && flutter build apk --release

# View Firestore data
firebase firestore:indexes

# Check Flutter doctor
flutter doctor

# Clean and rebuild
flutter clean && flutter pub get && flutter run
```
