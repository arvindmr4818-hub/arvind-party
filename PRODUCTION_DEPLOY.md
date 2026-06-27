# 🚀 ARVIND PARTY - PRODUCTION DEPLOYMENT GUIDE

## Prerequisites
- Ubuntu 20.04+ / Debian server
- Node.js 18+
- Docker + Docker Compose
- Domain name with SSL certificate

---

## STEP 1 — Clone & Setup

```bash
# Clone repository
git clone https://github.com/arvindmr4818-hub/arvind-party.git
cd arvind-party/arvind-party-backend

# Copy env template
cp .env.template .env

# Edit .env with your values
nano .env
```

---

## STEP 2 — Fill Required .env Values

**Minimum required for startup:**
```
PORT=5000
MONGO_URI=mongodb://localhost:27017/arvind_party
JWT_SECRET=<generate: openssl rand -base64 64>
JWT_REFRESH_SECRET=<generate: openssl rand -base64 64>
FIREBASE_PROJECT_ID=<from Firebase console>
FIREBASE_CLIENT_EMAIL=<from Firebase service account>
FIREBASE_PRIVATE_KEY=<from Firebase service account JSON>
AGORA_APP_ID=<from Agora console>
AGORA_APP_CERTIFICATE=<from Agora console>
ALLOWED_ORIGINS=https://yourdomain.com
```

---

## STEP 3 — Docker Deployment (Recommended)

```bash
# Start all services
docker-compose up -d

# Check all services running
docker-compose ps

# View logs
docker-compose logs -f backend

# Check health
curl http://localhost:5000/health
```

---

## STEP 4 — Manual Deployment (Without Docker)

```bash
# Install dependencies
npm install --production

# Start with PM2 (recommended)
npm install -g pm2
pm2 start server.js --name arvind-party-backend
pm2 save
pm2 startup

# Check status
pm2 status
pm2 logs arvind-party-backend
```

---

## STEP 5 — Nginx Reverse Proxy

```nginx
server {
    listen 80;
    server_name yourdomain.com;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name yourdomain.com;

    ssl_certificate /etc/letsencrypt/live/yourdomain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/yourdomain.com/privkey.pem;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;
    add_header Content-Security-Policy "default-src 'self'" always;

    location / {
        proxy_pass http://localhost:5000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        proxy_read_timeout 300s;
    }
}
```

---

## STEP 6 — SSL Certificate

```bash
# Install certbot
sudo apt install certbot python3-certbot-nginx

# Get SSL certificate
sudo certbot --nginx -d yourdomain.com

# Auto renewal test
sudo certbot renew --dry-run
```

---

## STEP 7 — Update Flutter App Config

In `lib/core/constants/env_config.dart`:
```dart
static const String plainApiBaseUrl = 'https://yourdomain.com/api';
static const String socketUrl = 'https://yourdomain.com';
```

---

## STEP 8 — Health Check Verification

```bash
# API health
curl https://yourdomain.com/health

# All routes working
curl https://yourdomain.com/api/auth

# Socket.IO
# Test from browser console: 
# const s = io('https://yourdomain.com'); s.on('connect', () => console.log('Connected!'));
```

---

## MONITORING

```bash
# Start with monitoring stack
docker-compose --profile monitoring up -d

# Prometheus: http://yourdomain.com:9090
# Grafana: http://yourdomain.com:3000 (admin/your_password)
```

---

## COMMON ISSUES

| Error | Fix |
|-------|-----|
| `MONGO_URI not set` | Add MONGO_URI to .env |
| `JWT_SECRET not set` | Add JWT_SECRET to .env |
| `Firebase error` | Check FIREBASE_PROJECT_ID, CLIENT_EMAIL, PRIVATE_KEY |
| `Redis connection failed` | Start Redis: `redis-server` or use Docker |
| `Port 5000 in use` | Change PORT in .env |
| `CORS error` | Add your domain to ALLOWED_ORIGINS in .env |

---

## SECURITY CHECKLIST ✅

- [ ] JWT_SECRET is random (min 64 chars)
- [ ] .env is in .gitignore
- [ ] Firebase keys from service account (not web config)
- [ ] ALLOWED_ORIGINS set to production domain only
- [ ] SSL certificate installed
- [ ] Firewall: only ports 80, 443, 22 open
- [ ] MongoDB not exposed to public internet
- [ ] Redis password set in production
