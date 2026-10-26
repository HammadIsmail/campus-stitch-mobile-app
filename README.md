# CampuStitch - Mobile Application (Flutter)


> **Next.js Web Repository**: [https://github.com/HammadIsmail/campus-stitch](https://github.com/HammadIsmail/campus-stitch)  
**CampuStitch Mobile** is a cross-platform Flutter application (Android & iOS) designed for verified university students across Pakistan. It provides a native mobile experience for daily rickshaw/carpool splits, peer bike rentals, student-to-student marketplace, hostel living, student services, and real-time push notifications.

---

## 🚀 Key Mobile Features

### 1. 🏢 Hostel Hub (`HostelScreen` - Primary Tab 1)
- **Roommate Vacancies:** Clean directory of verified student roommate listings across campus hostel blocks (published via web portal).
- **Student Services & Gigs:** Door-to-door campus services (laundry pickup, cooler maintenance, printing delivery) with direct provider contact.
- **Offer Campus Service:** Fast form with preset categories for student service providers.

### 2. 🚗 Commute & Carpooling (`CommuteScreen`)
- **Rickshaw & Carpool Splits:** Daily routes (e.g. Khurrianwala ⇄ Campus) splitting travel costs evenly among students.
- **Fair-Share Splitter:** Live recalculation of per-student costs as seats are booked.
- **Peer Bike Rentals:** Hourly and daily bike rentals with student ID verification.

### 3. 🛍️ Student Marketplace (`MarketScreen`)
- **Hyperlocal Campus Market:** Textbooks, lab equipment, cooler repairs, calculators, and furniture.
- **Pass-Out Room Bundles:** Graduating seniors bundle full room setups for incoming freshmen.

### 4. 🔔 Native Push Notifications (Firebase Cloud Messaging)
- **Firebase Messaging (`firebase_messaging`):** Native push reception for Android and iOS.
- **Local Heads-Up Notifications (`flutter_local_notifications`):** Displays alerts with high-priority banners when the app is in the foreground.
- **Background Handlers (`_firebaseMessagingBackgroundHandler`):** Handles background and terminated push events.
- **Automatic Token Synchronization:** Device tokens are automatically registered with the Next.js backend (`POST /api/notifications/token`) upon login.

### 5. 🛡️ Student Identity Verification (`VerificationScreen`)
- **Student Verification Submission:** Pure student-facing flow to upload live selfie and university student ID card.
- **Web-Only Administration:** Note that CampuStitch mobile has NO admin or super-admin screens/APIs. All administrative operations (KYC document verification, campus administration, super admin management) are handled exclusively on the Web portal (`/admin` and `/admin/super`).

---

## 🛠️ Architecture & Tech Stack

- **Framework:** [Flutter 3.47](https://flutter.dev/) with [Dart 3.13](https://dart.dev/)
- **Architecture:** Layered Architecture (`core/`, `models/`, `services/`, `screens/`)
- **Networking:** Pure-Dart `ApiClient` with 15-second OWASP timeout protection and automated Bearer token injection.
- **State Management:** Lightweight reactive `ChangeNotifier` (`AuthState`, `ThemeState`) without heavy third-party state boilerplate.
- **Notifications:** `firebase_core`, `firebase_messaging`, `flutter_local_notifications`.
- **Styling:** Material 3 with bespoke monochrome Light & Dark theme modes.

---

## 🏃 Getting Started

### Prerequisites
- Flutter SDK 3.47+ & Dart 3.13+
- Android Studio / Android SDK (API 34+)
- Connected Android device or Android Emulator

### 1. Clone the Repository
```bash
git clone https://github.com/HammadIsmail/campus-stitch-mobile-app.git
cd campus-stitch-mobile-app
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Firebase Setup (Android)
Ensure the `google-services.json` file is present in:
```
mobile/android/app/google-services.json
```
*(This connects the mobile app to your Firebase project `campus-stitch` with package name `com.campusstitch.app`).*

### 4. Run Analysis & Tests
```bash
flutter analyze   # Validates zero Dart errors
flutter test      # Runs test suite
```

### 5. Launch the App
```bash
flutter run
```

---

## 🌐 Connected Ecosystem
- **Web App**: [https://github.com/HammadIsmail/campus-stitch](https://github.com/HammadIsmail/campus-stitch)
- **API Documentation**: [docs/API_REFERENCE.md](../docs/API_REFERENCE.md)
- **System Architecture**: [docs/ARCHITECTURE.md](../docs/ARCHITECTURE.md)
- **Credentials & Runbook**: [docs/CREDENTIALS_AND_RUNBOOK.md](../docs/CREDENTIALS_AND_RUNBOOK.md)
