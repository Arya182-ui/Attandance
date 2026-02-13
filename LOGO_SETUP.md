# Logo Usage Instructions

## Current Logo Files:
- Student App: `assets/images/logo.svg` (Blue theme - Attendance checklist)
- Admin Panel: `assets/images/logo.svg` (Purple theme - Dashboard/Admin)

## To Replace with Your Logo:
1. Replace the logo.svg files with your logo.png:
   - Student App: `student_app/assets/images/logo.png`
   - Admin Panel: `admin_panel/assets/images/logo.png`

## For App Icons (Launcher Icons):

### Automatic Method (Recommended):
```bash
# Install flutter_launcher_icons
flutter pub add flutter_launcher_icons

# Add to pubspec.yaml:
dev_dependencies:
  flutter_launcher_icons: ^0.13.1

flutter_icons:
  android: true
  ios: true
  web: true
  image_path: "assets/images/logo.png"
  
# Generate icons
flutter pub run flutter_launcher_icons
```

### Manual Method:
1. Android Icons: Place icons in `android/app/src/main/res/mipmap-*/`
2. Web Icons: Place in `web/icons/` and update `web/index.html`

## Icon Sizes Needed:
- **Android**: 192x192, 144x144, 96x96, 72x72, 48x48
- **Web**: 512x512, 192x192, 72x72, 48x48
- **iOS**: Various sizes from 20x20 to 1024x1024

## Current Configuration:
- Assets are configured in `pubspec.yaml`
- Logo can be used in app with: `Image.asset('assets/images/logo.svg')`