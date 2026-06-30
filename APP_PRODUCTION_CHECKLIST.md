# 📱 ARVIND PARTY APP — PRODUCTION CHECKLIST

## ✅ Already Done (Code Level — 100%)
- LiveKit voice rooms (replaces Agora) — real implementation
- Auth: Firebase Phone OTP + Google Sign-In + backend JWT exchange
- Room system: seats, mic toggle, host controls, kick/mute, real-time via Socket.IO
- Gift system: send gift, coin deduction, real-time broadcast
- Wallet: Razorpay recharge (create order + verify signature), withdrawal requests
- Notifications: list, mark read, swipe-to-delete, real backend
- User service: profile, balance, session persistence
- main.dart: clean service init order
- pubspec.yaml: matches actual asset files (no broken references)
- Android build.gradle: google-services plugin added, package renamed

---

## 🔴 YOU MUST DO THESE (Cannot be automated)

### 1. Firebase Setup (15 min)
```
1. Go to https://console.firebase.google.com
2. Create project "Arvind Party"
3. Add Android app → package name: com.arvindparty.app
4. Download google-services.json
5. Replace: android/app/google-services.json (currently a placeholder)
6. Authentication tab → Enable "Phone" and "Google" sign-in providers
7. Project Settings → Service Accounts → Generate new private key
   → Use these values in backend .env:
     FIREBASE_PROJECT_ID, FIREBASE_CLIENT_EMAIL, FIREBASE_PRIVATE_KEY
```

### 2. App Server IP (2 min)
```dart
// lib/core/constants/env_config.dart
static const String devBaseUrl = 'http://YOUR_PC_IP:5000';
// Find your IP: 
//   Windows: ipconfig
//   Mac/Linux: ifconfig
```

### 3. LiveKit Server (5 min)
```bash
# On your backend server:
docker run -d --name livekit -p 7880:7880 -p 7881:7881 -p 7882:7882/udp \
  -v $(pwd)/livekit.yaml:/etc/livekit.yaml \
  livekit/livekit-server --config /etc/livekit.yaml

# Update lib/core/constants/env_config.dart:
static const String devLiveKitUrl = 'ws://YOUR_PC_IP:7880';
```

### 4. Razorpay (10 min)
```
1. Sign up at https://razorpay.com
2. Get API Keys from Dashboard → Settings → API Keys
3. Add to backend .env:
   RAZORPAY_KEY_ID=rzp_test_xxxx (or rzp_live_ for production)
   RAZORPAY_KEY_SECRET=xxxx
```

---

## 🧪 TESTING STEPS (Once above is done)

```bash
# 1. Start backend
cd arvind-party-backend
npm install
node src/utils/createAdmin.js
npm run dev

# 2. Start LiveKit (if not already running)
docker start livekit

# 3. Run Flutter app
flutter pub get
flutter run
# Connect phone via USB or use emulator (same WiFi as your PC)

# 4. Test flow:
#    - Open app → Login screen
#    - Enter phone number → Get OTP → Verify
#    - Should land on Home screen
#    - Create/Join a room → Should connect to LiveKit voice
#    - Send a gift → Coins should deduct
#    - Recharge coins → Razorpay checkout should open
```

---

## 📦 BUILD FOR PLAY STORE

### Generate signing key:
```bash
keytool -genkey -v -keystore arvind-release-key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias arvind
```

### Configure signing in android/app/build.gradle.kts:
```kotlin
signingConfigs {
    create("release") {
        storeFile = file("../arvind-release-key.jks")
        storePassword = "YOUR_PASSWORD"
        keyAlias = "arvind"
        keyPassword = "YOUR_PASSWORD"
    }
}
buildTypes {
    release {
        signingConfig = signingConfigs.getByName("release")
    }
}
```

### Build:
```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
# Upload this .aab to Google Play Console
```

---

## 🌐 PRODUCTION ENV CONFIG

Before going live, set `isProduction = true` in env_config.dart and build with:
```bash
flutter build appbundle --release \
  --dart-define=IS_PRODUCTION=true \
  --dart-define=API_BASE_URL=https://api.yourdomain.com \
  --dart-define=LIVEKIT_URL=wss://livekit.yourdomain.com
```

---

## 📋 QUICK STATUS

| Component | Status |
|-----------|--------|
| Voice Rooms (LiveKit) | ✅ Code complete — needs server running |
| Auth (Phone OTP + Google) | ✅ Code complete — needs Firebase config |
| Gifts | ✅ Code complete — ready to test |
| Wallet/Payments | ✅ Code complete — needs Razorpay keys |
| Notifications | ✅ Code complete — ready to test |
| Backend API | ✅ Code complete — needs .env filled |
| Android Build Config | ✅ Fixed — needs real google-services.json |
| Assets (fonts/images) | ✅ Fixed — pubspec matches actual files |
