# Indus Virtual School — Flutter app

Flutter port of the website homepage, with Firebase login / sign up (email + Google).

## 1. Generate platform folders (once)
This repo contains only the Dart code and assets. From the project root run:
```bash
flutter create . --project-name indus_virtual_school --platforms=android,ios
rm -f test/widget_test.dart   # default test references a different app class
flutter pub get
```
Android: in `android/app/build.gradle(.kts)` set `minSdk = 23` (needed by Firebase).

## 2. Connect Firebase
```bash
dart pub global activate flutterfire_cli
flutterfire configure
```
Pick your Firebase project and platforms. This overwrites `lib/firebase_options.dart` and adds
`google-services.json` / `GoogleService-Info.plist`.
In Firebase Console → Authentication → Sign-in method, enable **Email/Password** and **Google**.

## 3. Run / build
```bash
flutter run
flutter build apk --release       # Android
flutter build appbundle           # Play Store
```
Without Firebase config the app still runs; the auth forms show a "not configured" notice.
