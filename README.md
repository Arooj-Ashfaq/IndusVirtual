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

## Admission form (Firestore + Storage)
The 3-step form (Personal / Parents / Education) saves to the same Firebase project:
- **Firestore** → collection `admissions`, one document per user (`admissions/{uid}`), `status: "pending"`.
- **Storage** → `admissions/{uid}/cnic.<ext>` (the uploaded CNIC / B-Form).
- The password is used only to create the Firebase Auth account; it is never stored in Firestore.

Setup in Firebase Console:
1. **Build → Firestore Database → Create database**, then **Rules** tab → paste `firestore.rules` → **Publish**.
2. **Build → Storage → Get started**, then **Rules** tab → paste `storage.rules` → **Publish**.
   (New Firebase projects may require the Blaze pay-as-you-go plan to enable Storage.)
3. Review applications in **Firestore Database → Data → admissions**.

Run `flutter pub get` again after pulling (new packages: cloud_firestore, firebase_storage, file_picker).
