# CampuStitch - Mobile Application (Flutter)


> **Next.js Web Repository**: [https://github.com/HammadIsmail/campus-stitch](https://github.com/HammadIsmail/campus-stitch)  
**CampuStitch Mobile** is a cross-platform Flutter application (Android & iOS) designed for verified university students across Pakistan. It provides a native mobile experience for daily rickshaw/carpool splits, peer bike rentals, student-to-student marketplace, hostel living, Reddit-style campus community feed, and real-time push notifications.

---

## 🚀 Key Mobile Features

### 1. 🔔 Native Push Notifications (Firebase Cloud Messaging)
- **Firebase Messaging (`firebase_messaging`):** Native push reception for Android and iOS.
- **Local Heads-Up Notifications (`flutter_local_notifications`):** Displays alerts with high-priority banners when the app is in the foreground.
- **Background Handlers (`_firebaseMessagingBackgroundHandler`):** Handles background and terminated push events.
- **Automatic Token Synchronization:** Device tokens are automatically registered with the Next.js backend (`POST /api/notifications/token`) upon login.

### 2. 👥 Campus Feed with Infinite Scroll (`CommunityScreen`)
- **Initial Batch of 3 Posts:** Loads only the first 3 posts upon opening for instant loading.
- **ScrollController Infinite Scroll:** Dynamically loads the next 3 posts as the user scrolls near the bottom of the list.
- **Upvoting & Downvoting:** Optimistic score feedback with server sync.
- **Subreddit Filtering:** Switch between `All Feeds`, `r/general`, `r/exams`, `r/commute-splits`, and `r/cs-uet`.

### 3. 🚗 Commute & Carpooling (`CommuteScreen`)
- **Rickshaw Cost Splits:** Fixed daily routes (e.g. Khurrianwala ⇄ UET Lahore) splitting fares evenly among students.
- **Fair-Share Splitter:** Live recalculation of per-student costs as seats are booked.
- **Peer Bike Rentals:** Hourly and daily bike rentals with student ID verification.

### 4. 🛍️ Student Marketplace (`MarketScreen`)
- **Hyperlocal Campus Market:** Textbooks, lab equipment, cooler repairs, calculators, and furniture.
- **Pass-Out Room Bundles:** Graduating seniors bundle full room setups for incoming freshmen.

### 5. 🏢 Hostel Hub (`HostelScreen`)
- **Roommate Vacancies:** Listings for shared rooms, attached washrooms, and hostel vacancies across university blocks.
- **Student Services:** Door-to-door campus services (laundry pickup, electricians, past paper delivery).

### 6. 🛡️ Student Identity Verification (`VerificationScreen`)
- **Student KYC Submission:** Pure student-facing flow to upload live selfie and university student ID card.
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
