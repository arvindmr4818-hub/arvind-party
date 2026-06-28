# 🚀 ARVIND PARTY — QUICK START GUIDE

## Prerequisites
- Node.js 18+
- MongoDB (local or Atlas)
- Flutter 3.x
- Docker (optional but recommended)

---

## BACKEND (5 minutes)

```bash
cd arvind-party-backend

# 1. Setup environment
cp .env.template .env

# 2. Edit .env — minimum required:
# MONGO_URI=mongodb://localhost:27017/arvind_party
# JWT_SECRET=any_long_random_string_here_64_chars
# JWT_REFRESH_SECRET=another_long_random_string_64_chars
# LIVEKIT_API_KEY=devkey
# LIVEKIT_API_SECRET=secret
# LIVEKIT_SERVER_URL=ws://localhost:7880

# 3. Install dependencies
npm install

# 4. Create first admin account
node src/utils/createAdmin.js
# → Shows: Email + Password to login

# 5. Start server
npm run dev
# → Server: http://localhost:5000
# → Test: http://localhost:5000/health
```

---

## LIVEKIT (Voice Rooms — Free)

```bash
# Option 1: Docker (easiest)
docker run -d --name livekit \
  -p 7880:7880 -p 7881:7881 -p 7882:7882/udp \
  -v $(pwd)/livekit.yaml:/etc/livekit.yaml \
  livekit/livekit-server --config /etc/livekit.yaml

# Option 2: Binary
curl -sSL https://get.livekit.io | bash
livekit-server --config livekit.yaml --dev
```

---

## WEB ADMIN PANEL (Browser)

```bash
cd arvind_party_web

# Install Flutter packages
flutter pub get

# Run in Chrome (connects to localhost:5000 automatically)
flutter run -d chrome

# Login with credentials from createAdmin.js
```

---

## PRODUCTION DEPLOYMENT

### Backend on Ubuntu server:
```bash
# Install dependencies
sudo apt update && sudo apt install -y nodejs npm mongodb docker.io

# Clone repo
git clone https://github.com/arvindmr4818-hub/arvind-party.git
cd arvind-party/arvind-party-backend

# Fill .env with production values
cp .env.template .env && nano .env

# Start with Docker
docker-compose up -d

# OR with PM2
npm install -g pm2
npm install
node src/utils/createAdmin.js
pm2 start server.js --name arvind-party
pm2 save && pm2 startup
```

### Web Panel Production Build:
```bash
cd arvind_party_web
flutter build web \
  --dart-define=BACKEND_URL=https://api.yourdomain.com/api

# Deploy build/web/ to S3, Nginx, or Firebase Hosting
```

### AWS S3 + CloudFront (for web panel):
```bash
aws s3 sync build/web/ s3://your-bucket-name --delete
# Then invalidate CloudFront cache
```

---

## TEST YOUR SETUP

```bash
# 1. Backend health
curl http://localhost:5000/health

# 2. Admin login
curl -X POST http://localhost:5000/api/auth/admin-login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin@arvindparty.com","password":"Admin@123456"}'

# 3. Get LiveKit token (replace TOKEN and ROOM_ID)
curl -X POST http://localhost:5000/api/room/TEST123/livekit/token \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"role":"host"}'
```

---

## QUICK CHECKLIST BEFORE PRODUCTION

- [ ] Change JWT_SECRET to a real random string
- [ ] Set MONGO_URI to MongoDB Atlas (or secured MongoDB)
- [ ] Change LIVEKIT_API_KEY and LIVEKIT_API_SECRET
- [ ] Set your domain in ALLOWED_ORIGINS
- [ ] Change admin password after first login
- [ ] Add Razorpay keys for real payments
- [ ] Add YOUTUBE_API_KEY for video search
- [ ] Set up SSL/HTTPS with certbot
- [ ] Open firewall: 80, 443, 5000, 7880-7882
