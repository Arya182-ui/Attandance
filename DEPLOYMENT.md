# Deployment Guide

## Production Deployment Checklist

### Pre-Deployment

- [ ] Test all features thoroughly
- [ ] Review and update Firebase security rules
- [ ] Configure environment variables
- [ ] Set up proper error tracking
- [ ] Enable Firebase Analytics
- [ ] Configure App Check
- [ ] Review API key restrictions
- [ ] Set up budget alerts in Firebase

## Student Mobile App Deployment

### Android

#### 1. Update App Configuration

Edit `student_app/android/app/build.gradle`:
```gradle
android {
    defaultConfig {
        applicationId "com.geofenced.attendance.student_app"
        minSdkVersion 21
        targetSdkVersion 33
        versionCode 1
        versionName "1.0.0"
    }
}
```

#### 2. Create Keystore

```bash
cd student_app/android
keytool -genkey -v -keystore attendance-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias attendance
```

#### 3. Configure Signing

Create `android/key.properties`:
```properties
storePassword=<password>
keyPassword=<password>
keyAlias=attendance
storeFile=<path-to-keystore>
```

Update `android/app/build.gradle`:
```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

#### 4. Build Release APK

```bash
cd student_app
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

#### 5. Build App Bundle (For Google Play)

```bash
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

#### 6. Deploy to Google Play Store

1. Go to [Google Play Console](https://play.google.com/console)
2. Create a new app
3. Upload the AAB file
4. Complete store listing
5. Submit for review

### iOS

#### 1. Update App Configuration

Edit `student_app/ios/Runner/Info.plist`:
```xml
<key>CFBundleDisplayName</key>
<string>Student Attendance</string>
<key>CFBundleIdentifier</key>
<string>com.geofenced.attendance.studentApp</string>
```

#### 2. Open Xcode Project

```bash
cd student_app
open ios/Runner.xcworkspace
```

#### 3. Configure Signing

In Xcode:
1. Select Runner project
2. Select "Signing & Capabilities"
3. Choose your development team
4. Ensure "Automatically manage signing" is checked

#### 4. Build Archive

In Xcode:
1. Select "Any iOS Device" as target
2. Product → Archive
3. Wait for build to complete

#### 5. Deploy to App Store

1. Click "Distribute App"
2. Choose "App Store Connect"
3. Upload
4. Go to [App Store Connect](https://appstoreconnect.apple.com)
5. Complete app information
6. Submit for review

## Admin Web Panel Deployment

### Build for Production

```bash
cd admin_panel
flutter build web --release
```

Output: `build/web/`

### Option 1: Firebase Hosting

#### 1. Initialize Firebase Hosting

```bash
firebase init hosting
```

Configuration:
- Public directory: `build/web`
- Single-page app: Yes
- Overwrite index.html: No

#### 2. Deploy

```bash
firebase deploy --only hosting
```

Your admin panel will be available at: `https://your-project.web.app`

#### 3. Configure Custom Domain (Optional)

1. Go to Firebase Console → Hosting
2. Add custom domain
3. Follow DNS configuration steps

### Option 2: Netlify

#### 1. Install Netlify CLI

```bash
npm install -g netlify-cli
```

#### 2. Deploy

```bash
cd admin_panel
netlify deploy --dir=build/web --prod
```

### Option 3: Vercel

#### 1. Install Vercel CLI

```bash
npm install -g vercel
```

#### 2. Deploy

```bash
cd admin_panel
vercel --prod
```

### Option 4: Traditional Web Server

1. Copy `build/web` contents to server
2. Configure web server (nginx/apache)
3. Ensure HTTPS is enabled

**Nginx Configuration:**
```nginx
server {
    listen 443 ssl;
    server_name admin.yourdomain.com;
    
    root /var/www/admin-panel;
    index index.html;
    
    location / {
        try_files $uri $uri/ /index.html;
    }
}
```

## Environment Configuration

### Production Firebase Project

Create separate Firebase projects for staging and production:

1. **Development** - For testing
2. **Production** - For live users

Configure each app:
```bash
# Development
flutterfire configure --project=attendance-dev

# Production
flutterfire configure --project=attendance-prod
```

### Environment Variables

For sensitive configuration, use environment variables or Flutter flavors.

## Post-Deployment

### Monitoring

1. **Firebase Console**
   - Monitor authentication
   - Check Firestore usage
   - Review storage usage

2. **Analytics**
   - Track user engagement
   - Monitor check-in success rates
   - Identify error patterns

3. **Crashlytics**
   - Monitor app crashes
   - Track error rates
   - Review stack traces

### Maintenance

#### Regular Tasks
- [ ] Monitor Firebase usage and costs
- [ ] Review security rules
- [ ] Update dependencies
- [ ] Check for Flutter updates
- [ ] Backup Firestore data
- [ ] Review user feedback

#### Monthly Reviews
- [ ] Analyze usage patterns
- [ ] Review attendance data integrity
- [ ] Check for security issues
- [ ] Update documentation
- [ ] Performance optimization

## Scaling Considerations

### As User Base Grows

1. **Firestore Optimization**
   - Create composite indexes
   - Implement pagination
   - Use subcollections for large datasets

2. **Authentication**
   - Consider rate limiting
   - Implement CAPTCHA for web
   - Use Firebase App Check

3. **Storage**
   - Implement image compression
   - Set up Cloud Functions for processing
   - Configure lifecycle policies

4. **Costs**
   - Monitor Firebase usage
   - Set up budget alerts
   - Optimize queries
   - Use caching where appropriate

## Troubleshooting Production Issues

### High Costs

1. Check Firestore read/write operations
2. Review Cloud Storage usage
3. Optimize queries
4. Implement caching

### Performance Issues

1. Enable performance monitoring
2. Optimize images
3. Implement lazy loading
4. Use pagination

### Security Concerns

1. Review Firestore rules
2. Enable App Check
3. Implement rate limiting
4. Monitor unusual activity

## Rollback Plan

In case of critical issues:

1. **Mobile Apps**
   - Push bug fix update
   - Users must update to continue

2. **Web Panel**
   - Revert to previous deployment
   - Firebase Hosting: `firebase hosting:rollback`
   - Netlify/Vercel: Revert from dashboard

3. **Database**
   - Restore from Firestore backup
   - Use export/import feature

## Support

### User Support

1. Create FAQs document
2. Set up support email
3. Monitor app reviews
4. Provide in-app help

### Developer Support

1. Document common issues
2. Maintain changelog
3. Keep architecture docs updated
4. Regular team training

## Continuous Integration

### GitHub Actions (Example)

Create `.github/workflows/deploy.yml`:
```yaml
name: Deploy
on:
  push:
    branches: [ main ]

jobs:
  deploy-web:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
      - run: cd admin_panel && flutter build web
      - uses: FirebaseExtended/action-hosting-deploy@v0
        with:
          repoToken: '${{ secrets.GITHUB_TOKEN }}'
          firebaseServiceAccount: '${{ secrets.FIREBASE_SERVICE_ACCOUNT }}'
          projectId: your-project-id
```

---

**Remember**: Always test thoroughly in a staging environment before deploying to production!
