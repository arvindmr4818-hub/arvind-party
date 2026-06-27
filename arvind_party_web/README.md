# Arvind Party Web Admin Panel

## 🚀 Run Locally

```bash
cd arvind_party_web
flutter pub get
flutter run -d chrome
```

Backend must be running at `http://localhost:5000`

## 🏗️ Build for Production

```bash
flutter build web \
  --dart-define=BACKEND_URL=https://api.yourdomain.com/api \
  --dart-define=SOCKET_URL=https://api.yourdomain.com \
  --dart-define=FIREBASE_API_KEY=your_key \
  --dart-define=FIREBASE_PROJECT_ID=your_project_id \
  --dart-define=FIREBASE_APP_ID=your_app_id

# Deploy build/web/ to your web server or CDN
```

## 📋 All Admin Pages (30+)

| Page | Route | Access |
|------|-------|--------|
| Dashboard | /dashboard | All Admin |
| Users | /users | All Admin |
| Staff | /staff | Admin+ |
| Rooms | /rooms | All Admin |
| Gifts | /gifts | All Admin |
| Transactions | /transactions | Finance+ |
| Wallet Management | /wallet-management | Finance+ |
| **Coin Manager** | /coin-manager | **OWNER ONLY** |
| Agency | /agency | All Admin |
| VIP System | /vip-admin | All Admin |
| Events | /events | All Admin |
| Games | /games | All Admin |
| Leaderboard | /leaderboard | All Admin |
| Families | /families | All Admin |
| PK Battle | /pk-battle-management | All Admin |
| Notifications | /notifications | Admin+ |
| Reports | /reports | Finance+ |
| Analytics | /analytics-dashboard | All Admin |
| Security | /security | Admin+ |
| Monitoring | /infrastructure/monitoring | Super Admin |
| Support Tickets | /support | Support+ |
| Settings | /settings | Owner+ |
| Localization | /localization | Admin+ |

## 🔑 Admin Login

Default admin must be created in MongoDB:

```javascript
// Run in MongoDB shell:
db.users.insertOne({
  name: "Super Admin",
  username: "admin",
  email: "admin@arvindparty.com",
  password: "$2a$12$...", // bcrypt hash of your password
  role: "owner",
  isActive: true,
  createdAt: new Date()
})
```

Or use the backend seeder:
```bash
cd arvind-party-backend
node src/utils/createAdmin.js
```

## 🔒 Role Hierarchy

```
owner > super_admin > admin > finance > moderator > support > content_manager
```

- **owner**: All access including Coin Manager
- **admin**: All except Coin Manager
- **moderator**: Users, Rooms, Support
- **support**: Support tickets only
- **finance**: Transactions, Wallet, Reports
