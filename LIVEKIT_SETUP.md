# 🎙️ LiveKit Setup Guide — Free Self-Hosted Voice Rooms

## What is LiveKit?
LiveKit is a **free, open-source** WebRTC server for voice/video rooms.
- 100% free (self-host on any server)
- Works on AWS, DigitalOcean, VPS, etc.
- Replaces Agora (which costs money)

---

## STEP 1 — Install LiveKit on your server

```bash
# Ubuntu/Debian server
curl -sSL https://get.livekit.io | bash

# OR with Docker (easiest):
docker run -d --name livekit \
  --restart unless-stopped \
  -p 7880:7880 \
  -p 7881:7881 \
  -p 7882:7882/udp \
  -v $(pwd)/livekit.yaml:/etc/livekit.yaml \
  livekit/livekit-server --config /etc/livekit.yaml
```

## STEP 2 — Configure livekit.yaml

Edit `livekit.yaml` (already in your repo):
```yaml
keys:
  YOUR_API_KEY: YOUR_API_SECRET    # Change these!
rtc:
  # node_ip: YOUR_SERVER_PUBLIC_IP  # Uncomment for production!
```

## STEP 3 — Add to .env

```env
LIVEKIT_API_KEY=YOUR_API_KEY
LIVEKIT_API_SECRET=YOUR_API_SECRET
LIVEKIT_SERVER_URL=wss://livekit.yourdomain.com
```

## STEP 4 — SSL for Production

```bash
# With Nginx:
server {
    listen 443 ssl;
    server_name livekit.yourdomain.com;
    
    location / {
        proxy_pass http://localhost:7880;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
```

## STEP 5 — Install in backend

```bash
cd arvind-party-backend
npm install livekit-server-sdk
```

## STEP 6 — Flutter App Integration

Add to `pubspec.yaml`:
```yaml
livekit_client: ^2.1.8
```

Then in room view:
```dart
import 'package:livekit_client/livekit_client.dart';

// Connect to room
final room = Room();
await room.connect(serverUrl, token);
```

## API Endpoints (already implemented)

- `POST /api/room/:roomId/livekit/token` → Get join token
- `GET /api/room/:roomId/livekit/participants` → List participants
- `POST /api/room/:roomId/seat/occupy` → Take a seat
- `POST /api/room/:roomId/seat/leave` → Leave seat
- `POST /api/room/:roomId/host/mute` → Mute user
- `POST /api/room/:roomId/host/kick` → Kick user

## Quick Test

```bash
# Start backend
npm run dev

# Get token
curl -X POST http://localhost:5000/api/room/TEST_ROOM_ID/livekit/token \
  -H "Authorization: Bearer YOUR_JWT" \
  -H "Content-Type: application/json" \
  -d '{"role": "host"}'

# Response: { token: "...", serverUrl: "ws://localhost:7880" }
```
