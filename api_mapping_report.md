# API Endpoint Mapping Report

> **Generated on:** 19-Jun-2026
> **Flutter App Base URL:** `http://10.0.2.2:5000/api` (Dev) / `https://api.arvindparty.com` (Prod)
> **Backend Base URL:** `http://localhost:5000` / `http://10.0.2.2:5000`

---

## 1. Authentication Endpoints

| # | Flutter Endpoint | Backend Endpoint | Status |
|---|---|---|---|
| 1 | `POST /auth/signup` | `POST /api/auth/register` | **MISMATCH** (signup vs register) |
| 2 | `POST /auth/login` | `POST /api/auth/login` | ✅ MATCH |
| 3 | `POST /auth/logout` | `POST /api/auth/logout` | ✅ MATCH |
| 4 | `POST /auth/change-password` | ❌ Not available | **MISSING in Backend** |
| 5 | ❌ Not available | `POST /api/auth/send-otp` | **MISSING in Flutter** |
| 6 | ❌ Not available | `POST /api/auth/verify-otp` | **MISSING in Flutter** |
| 7 | ❌ Not available | `POST /api/auth/resend-otp` | **MISSING in Flutter** |
| 8 | ❌ Not available | `POST /api/auth/refresh-token` | **MISSING in Flutter** |
| 9 | ❌ Not available | `GET /api/auth/me` | **MISSING in Flutter** |

**Summary:** Backend uses OTP-based auth flow (send-otp, verify-otp, resend-otp). Flutter uses direct signup/login with password change. Significant mismatch.

---

## 2. User / Profile Endpoints

| # | Flutter Endpoint | Backend Endpoint | Status |
|---|---|---|---|
| 10 | `GET /users/profile` | `GET /api/auth/me` | **MISMATCH** (route differs) |
| 11 | `PUT /users/profile` | `POST /api/users/complete-profile` | **MISMATCH** (PUT vs POST, route differs) |
| 12 | `POST /users/follow/{userId}` | `POST /api/social/follow` | **MISMATCH** (route differs) |
| 13 | `POST /users/unfollow/{userId}` | `POST /api/social/follow` (toggle) | **MISMATCH** (single toggle vs separate routes) |
| 14 | `GET /users/search` | ❌ Not available | **MISSING in Backend** |
| 15 | ❌ Not available | `GET /api/users/center` | **MISSING in Flutter** |
| 16 | ❌ Not available | `POST /api/users/equip-frame` | **MISSING in Flutter** |
| 17 | `POST /users/status` | ❌ Not available | **MISSING in Backend** |
| 18 | `GET /users/{userId}/status` | ❌ Not available | **MISSING in Backend** |
| 19 | `GET /user/profile` | `GET /api/auth/me` | **MISMATCH** (route differs) |
| 20 | `PUT /user/profile` | `POST /api/users/complete-profile` | **MISMATCH** |
| 21 | `GET /user/balance` | `GET /api/wallet` | **MISMATCH** (route differs) |

---

## 3. Profile (User Profile Feature)

| # | Flutter Endpoint | Backend Endpoint | Status |
|---|---|---|---|
| 22 | `GET /profile/me` | `GET /api/auth/me` | **MISMATCH** (route differs) |
| 23 | `GET /profile/{userId}` | ❌ Not available | **MISSING in Backend** |
| 24 | `PUT /profile/update` | `POST /api/users/complete-profile` | **MISMATCH** |
| 25 | `POST /profile/avatar` | ❌ Not available | **MISSING in Backend** |
| 26 | `POST /profile/cover` | ❌ Not available | **MISSING in Backend** |
| 27 | `POST /profile/{userId}/follow` | `POST /api/social/follow` | **MISMATCH** |
| 28 | `POST /profile/{userId}/unfollow` | `POST /api/social/follow` (toggle) | **MISMATCH** |
| 29 | `POST /profile/{userId}/block` | `POST /api/moderation/block` | **MISMATCH** |
| 30 | `POST /profile/{userId}/unblock` | ❌ Not available | **MISSING in Backend** |
| 31 | `GET /profile/{userId}/followers` | ❌ Not available | **MISSING in Backend** |
| 32 | `GET /profile/{userId}/following` | ❌ Not available | **MISSING in Backend** |
| 33 | `GET /profile/{userId}/stats` | ❌ Not available | **MISSING in Backend** |
| 34 | `GET /profile/search` | ❌ Not available | **MISSING in Backend** |
| 35 | `PUT /profile/privacy` | ❌ Not available | **MISSING in Backend** |

---

## 4. Room Endpoints

| # | Flutter Endpoint | Backend Endpoint | Status |
|---|---|---|---|
| 36 | `GET /rooms` | `GET /api/rooms` (via main routes) | ✅ MATCH |
| 37 | `POST /rooms` | `POST /api/rooms/create` | **MISMATCH** (POST /rooms vs POST /rooms/create) |
| 38 | `POST rooms/create` | `POST /api/rooms/create` | ✅ MATCH |
| 39 | `PUT /rooms/{roomId}` | ❌ Not available (via room.routes.js) | **MISSING in Backend** |
| 40 | `DELETE /rooms/{roomId}` | ❌ Not available | **MISSING in Backend** |
| 41 | `POST /rooms/{roomId}/join` | ❌ Not available | **MISSING in Backend** |
| 42 | `POST /rooms/{roomId}/leave` | ❌ Not available | **MISSING in Backend** |
| 43 | `GET /rooms/list` | `GET /api/rooms/live` | **MISMATCH** (route name differs) |
| 44 | `GET /rooms/live` | `GET /api/rooms/live` | ✅ MATCH |
| 45 | `GET /rooms/discover` | ❌ Not available | **MISSING in Backend** |
| 46 | `GET /rooms/search` | ❌ Not available | **MISSING in Backend** |
| 47 | `GET /rooms/{roomId}/moderation` | ❌ Not available | **MISSING in Backend** |
| 48 | `GET /room/settings` | ❌ Not available | **MISSING in Backend** |
| 49 | `POST /room/settings` | ❌ Not available | **MISSING in Backend** |

---

## 5. Gift Endpoints

| # | Flutter Endpoint | Backend Endpoint | Status |
|---|---|---|---|
| 50 | `GET /gifts` | `GET /api/gifts/list` | **MISMATCH** |
| 51 | `POST /gifts/send` | `POST /api/gifts/send` | ✅ MATCH |
| 52 | `GET /gifts/history` | ❌ Not available | **MISSING in Backend** |
| 53 | `GET /gifts/available` | `GET /api/gifts/list` | **MISMATCH** |
| 54 | `GET /gifts/sent` | ❌ Not available | **MISSING in Backend** |
| 55 | `GET /gifts/received` | ❌ Not available | **MISSING in Backend** |
| 56 | `GET /gifts/ranking` | ❌ Not available | **MISSING in Backend** |
| 57 | `GET /gifts/{id}` | ❌ Not available | **MISSING in Backend** |

---

## 6. Wallet & Payment Endpoints

| # | Flutter Endpoint | Backend Endpoint | Status |
|---|---|---|---|
| 58 | `GET /wallet/balance` | `GET /api/wallet` | **MISMATCH** |
| 59 | `GET /wallet/packages` | ❌ Not available | **MISSING in Backend** |
| 60 | `GET /wallet/withdraw-methods` | ❌ Not available | **MISSING in Backend** |
| 61 | `GET /wallet/withdrawal-methods` | ❌ Not available | **MISSING in Backend** |
| 62 | `GET /wallet/transactions` | `GET /api/wallet/transactions` | ✅ MATCH |
| 63 | `POST /wallet/withdraw` | `POST /api/wallet/withdraw` | ✅ MATCH |
| 64 | ❌ Not available | `POST /api/wallet/razorpay/order` | **MISSING in Flutter** |
| 65 | ❌ Not available | `POST /api/wallet/razorpay/verify` | **MISSING in Flutter** |
| 66 | ❌ Not available | `POST /api/wallet/razorpay/webhook` | **MISSING in Flutter** |
| 67 | ❌ Not available | `GET /api/wallet/withdrawals` | **MISSING in Flutter** |
| 68 | ❌ Not available | `POST /api/wallet/send-gift` | **MISSING in Flutter** (uses /gifts/send instead) |

---

## 7. Friend / Social Endpoints

| # | Flutter Endpoint | Backend Endpoint | Status |
|---|---|---|---|
| 69 | `GET /friends` | `GET /api/social/connections` | **MISMATCH** |
| 70 | `GET /friends/followers` | `GET /api/social/connections` | **MISMATCH** |
| 71 | `GET /friends/following` | `GET /api/social/connections` | **MISMATCH** |
| 72 | `GET /friends/mutual` | ❌ Not available | **MISSING in Backend** |
| 73 | `GET /friends/requests/incoming` | ❌ Not available | **MISSING in Backend** |
| 74 | `GET /friends/requests/outgoing` | ❌ Not available | **MISSING in Backend** |
| 75 | `POST /friends/request` | ❌ Not available | **MISSING in Backend** |
| 76 | `PUT /friends/request/{requestId}/accept` | ❌ Not available | **MISSING in Backend** |
| 77 | `DELETE /friends/request/{requestId}` | ❌ Not available | **MISSING in Backend** |
| 78 | `POST /friends/follow` | `POST /api/social/follow` | ✅ MATCH |
| 79 | `DELETE /friends/follow` | `POST /api/social/follow` (toggle) | **MISMATCH** (DELETE vs POST) |
| 80 | `DELETE /friends/{userId}` | ❌ Not available | **MISSING in Backend** |
| 81 | ❌ Not available | `GET /api/social/cp/status` | **MISSING in Flutter** |
| 82 | ❌ Not available | `POST /api/social/cp/request` | **MISSING in Flutter** |
| 83 | ❌ Not available | `POST /api/social/cp/respond` | **MISSING in Flutter** |

---

## 8. Chat / Message Endpoints

| # | Flutter Endpoint | Backend Endpoint | Status |
|---|---|---|---|
| 84 | `GET /chats/{chatId}/messages` | `GET /api/chat/history/:userId/:targetId` | **MISMATCH** |
| 85 | `GET /chats/{chatId}` | ❌ Not available | **MISSING in Backend** |
| 86 | `GET /chat/{roomId}/messages` | `GET /api/chat/history/:userId/:targetId` | **MISMATCH** |
| 87 | `POST /chat/{roomId}/messages` | ❌ Not available | **MISSING in Backend** |
| 88 | `GET /messages/private/chats` | ❌ Not available | **MISSING in Backend** |
| 89 | `GET /messages/private/{userId}` | ❌ Not available | **MISSING in Backend** |
| 90 | `POST /messages/private/send` | ❌ Not available | **MISSING in Backend** |
| 91 | `POST /messages/private/upload` | ❌ Not available | **MISSING in Backend** |
| 92 | `POST /messages/private/{messageId}/read` | ❌ Not available | **MISSING in Backend** |
| 93 | `POST /messages/private/{userId}/read-all` | ❌ Not available | **MISSING in Backend** |
| 94 | `DELETE /messages/private/{messageId}` | ❌ Not available | **MISSING in Backend** |
| 95 | `PUT /messages/private/{messageId}` | ❌ Not available | **MISSING in Backend** |
| 96 | `POST /messages/private/{userId}/typing` | ❌ Not available | **MISSING in Backend** |

---

## 9. Notification Endpoints

| # | Flutter Endpoint | Backend Endpoint | Status |
|---|---|---|---|
| 97 | `GET /notifications` | ❌ Not available | **MISSING in Backend** |
| 98 | `PUT /notifications/{notificationId}/read` | ❌ Not available | **MISSING in Backend** |
| 99 | `PUT /notifications/mark-all-read` | ❌ Not available | **MISSING in Backend** |
| 100 | `DELETE /notifications/{notificationId}` | ❌ Not available | **MISSING in Backend** |

---

## 10. Moment Endpoints

| # | Flutter Endpoint | Backend Endpoint | Status |
|---|---|---|---|
| 101 | `GET /moments` | ❌ Not available | **MISSING in Backend** |
| 102 | `POST /moments/create` | ❌ Not available | **MISSING in Backend** |
| 103 | `GET /moments/{momentId}` | ❌ Not available | **MISSING in Backend** |
| 104 | `POST /moments/{momentId}/like` | ❌ Not available | **MISSING in Backend** |
| 105 | `POST /moments/{momentId}/unlike` | ❌ Not available | **MISSING in Backend** |
| 106 | `POST /moments/{momentId}/comment` | ❌ Not available | **MISSING in Backend** |
| 107 | `DELETE /moments/{momentId}/comment/{commentId}` | ❌ Not available | **MISSING in Backend** |
| 108 | `DELETE /moments/{momentId}` | ❌ Not available | **MISSING in Backend** |
| 109 | `GET /moments/search` | ❌ Not available | **MISSING in Backend** |

---

## 11. Block / Mute Endpoints

| # | Flutter Endpoint | Backend Endpoint | Status |
|---|---|---|---|
| 110 | `GET /block` | ❌ Not available | **MISSING in Backend** |
| 111 | `POST /block` | `POST /api/moderation/block` | **MISMATCH** |
| 112 | `DELETE /block/{userId}` | ❌ Not available | **MISSING in Backend** |
| 113 | `GET /mute` | ❌ Not available | **MISSING in Backend** |
| 114 | `POST /mute` | ❌ Not available | **MISSING in Backend** |
| 115 | `DELETE /mute/{userId}` | ❌ Not available | **MISSING in Backend** |

---

## 12. Home Endpoints

| # | Flutter Endpoint | Backend Endpoint | Status |
|---|---|---|---|
| 116 | `GET /home/banners` | ❌ Not available | **MISSING in Backend** |
| 117 | `GET /home/categories` | ❌ Not available | **MISSING in Backend** |

---

## 13. VIP Endpoints

| # | Flutter Endpoint | Backend Endpoint | Status |
|---|---|---|---|
| 118 | `GET /vip/tiers` | `GET /api/vip/plans` | **MISMATCH** |
| 119 | `GET /vip/status` | ❌ Not available | **MISSING in Backend** |
| 120 | `POST /vip/purchase` | `POST /api/vip/buy` | **MISMATCH** |
| 121 | `POST /vip/activate` | ❌ Not available | **MISSING in Backend** |

---

## 14. Backend-Only Routes (Not Used in Flutter)

| # | Backend Endpoint | Module | Status |
|---|---|---|---|
| 122 | `GET /api/admin/users` | Admin | ❌ Not used in Flutter |
| 123 | `POST /api/admin/users/ban` | Admin | ❌ Not used in Flutter |
| 124 | `POST /api/staff/login` | Staff | ❌ Not used in Flutter |
| 125 | `POST /api/staff/create` | Staff | ❌ Not used in Flutter |
| 126 | `GET /api/staff/list` | Staff | ❌ Not used in Flutter |
| 127 | `PUT /api/staff/update/:id` | Staff | ❌ Not used in Flutter |
| 128 | `DELETE /api/staff/delete/:id` | Staff | ❌ Not used in Flutter |
| 129 | `GET /api/agency/mine` | Agency | ❌ Not used in Flutter |
| 130 | `POST /api/agency/apply` | Agency | ❌ Not used in Flutter |
| 131 | `POST /api/pk-battles/request` | PK Battle | ❌ Not used in Flutter |
| 132 | `POST /api/pk-battles/accept` | PK Battle | ❌ Not used in Flutter |
| 133 | `POST /api/pk-battles/end` | PK Battle | ❌ Not used in Flutter |
| 134 | `GET /api/families/mine` | Family | ❌ Not used in Flutter |
| 135 | `POST /api/families/create` | Family | ❌ Not used in Flutter |
| 136 | `POST /api/families/join` | Family | ❌ Not used in Flutter |
| 137 | `GET /api/shop/items` | Shop | ❌ Not used in Flutter |
| 138 | `POST /api/shop/purchase` | Shop | ❌ Not used in Flutter |
| 139 | `GET /api/games/lucky-wheel/rewards` | Games | ❌ Not used in Flutter |
| 140 | `POST /api/games/lucky-wheel/spin` | Games | ❌ Not used in Flutter |
| 141 | `GET /api/cp/mine` | CP | ❌ Not used in Flutter |
| 142 | `POST /api/cp/bind` | CP | ❌ Not used in Flutter |
| 143 | `POST /api/treasury/generate` | Treasury | ❌ Not used in Flutter |
| 144 | `GET /api/treasury/logs` | Treasury | ❌ Not used in Flutter |
| 145 | `POST /api/matchmaking/search` | Matchmaking | ❌ Not used in Flutter |
| 146 | `POST /api/matchmaking/stop` | Matchmaking | ❌ Not used in Flutter |
| 147 | `GET /api/rankings/wealth` | Rankings | ❌ Not used in Flutter |
| 148 | `GET /api/rankings/charm` | Rankings | ❌ Not used in Flutter |
| 149 | `POST /api/app-users/join-agency` | App Users | ❌ Not used in Flutter |
| 150 | `POST /api/app-users/withdraw` | App Users | ❌ Not used in Flutter |
| 151 | `GET /api/inventory` | Inventory | ❌ Not used in Flutter |
| 152 | `POST /api/inventory/use/:itemId` | Inventory | ❌ Not used in Flutter |
| 153 | `DELETE /api/inventory/:itemId` | Inventory | ❌ Not used in Flutter |
| 154 | `GET /api/creator/earnings` | Creator | ❌ Not used in Flutter |
| 155 | `GET /api/creator/analytics` | Creator | ❌ Not used in Flutter |
| 156 | `POST /api/creator/withdraw` | Creator | ❌ Not used in Flutter |
| 157 | `GET /api/support/faq` | Support | ❌ Not used in Flutter |
| 158 | `GET /api/support/tickets` | Support | ❌ Not used in Flutter |
| 159 | `POST /api/support/ticket/create` | Support | ❌ Not used in Flutter |
| 160 | `POST /api/support/message` | Support | ❌ Not used in Flutter |
| 161 | `GET /api/moderation/reports` | Moderation | ❌ Not used in Flutter |
| 162 | `POST /api/moderation/report` | Moderation | ❌ Not used in Flutter |
| 163 | `GET /api/system/referral` | Referral | ❌ Not used in Flutter |
| 164 | `POST /api/system/referral/claim` | Referral | ❌ Not used in Flutter |
| 165 | `GET /api/users/:id/level` | Level | ❌ Not used in Flutter |
| 166 | `POST /api/users/xp/add` | Level | ❌ Not used in Flutter |
| 167 | `GET /api/health` | Health | ❌ Not used in Flutter |

---

## 15. Flutter-Only Endpoints (Commented/Suggested but No Backend)

These are endpoints found in Flutter repository files as comments (suggested API calls) but have no corresponding backend implementation.

| # | Flutter Endpoint (Commented) | Feature | Status |
|---|---|---|---|
| 168 | `GET /api/users/profile` | Profile Repo | ❌ MISSING in Backend |
| 169 | `GET /api/users/stats` | Profile Repo | ❌ MISSING in Backend |
| 170 | `PUT /api/users/profile` | Profile Repo | ❌ MISSING in Backend |
| 171 | `GET /api/users/followers` | Profile Repo | ❌ MISSING in Backend |
| 172 | `POST /api/users/:id/follow` | Profile Repo | ❌ MISSING in Backend |
| 173 | `POST /api/users/:id/unfollow` | Profile Repo | ❌ MISSING in Backend |
| 174 | `GET /api/users/:id` | Profile Repo | ❌ MISSING in Backend |
| 175 | `GET /api/notifications` | Notifications | ❌ MISSING in Backend |
| 176 | `POST /api/notifications/:id/read` | Notifications | ❌ MISSING in Backend |
| 177 | `DELETE /api/notifications/:id` | Notifications | ❌ MISSING in Backend |
| 178 | `POST /api/notifications/mark-all-read` | Notifications | ❌ MISSING in Backend |
| 179 | `GET /api/events` | Events | ❌ MISSING in Backend |
| 180 | `POST /api/events/:eventId/join` | Events | ❌ MISSING in Backend |
| 181 | `GET /api/events/:eventId` | Events | ❌ MISSING in Backend |
| 182 | `POST /api/events/:eventId/leave` | Events | ❌ MISSING in Backend |
| 183 | `GET /api/moments/feed` | Moments | ❌ MISSING in Backend |
| 184 | `POST /api/moments/create` | Moments | ❌ MISSING in Backend |
| 185 | `POST /api/moments/:id/like` | Moments | ❌ MISSING in Backend |
| 186 | `DELETE /api/moments/:id` | Moments | ❌ MISSING in Backend |
| 187 | `GET /api/moments/:id/comments` | Moments | ❌ MISSING in Backend |
| 188 | `POST /api/moments/:id/comments` | Moments | ❌ MISSING in Backend |
| 189 | `GET /api/lucky-draw/history` | Lucky Draw | ❌ MISSING in Backend |
| 190 | `POST /api/lucky-draw/spin` | Lucky Draw | ❌ MISSING in Backend |
| 191 | `GET /api/lucky-draw/prizes` | Lucky Draw | ❌ MISSING in Backend |
| 192 | `GET /api/shop/products` | Shop | ❌ MISSING in Backend |
| 193 | `GET /api/shop/products/:id` | Shop | ❌ MISSING in Backend |
| 194 | `POST /api/shop/checkout` | Shop | ❌ MISSING in Backend |
| 195 | `GET /api/shop/history` | Shop | ❌ MISSING in Backend |
| 196 | `GET /api/search` | Search | ❌ MISSING in Backend |
| 197 | `GET /api/search/rooms` | Search | ❌ MISSING in Backend |
| 198 | `GET /api/search/suggestions` | Search | ❌ MISSING in Backend |
| 199 | `GET /api/search/trending` | Search | ❌ MISSING in Backend |
| 200 | `GET /api/gifts/available` | Gift (Presentation) | ❌ MISSING in Backend |
| 201 | `GET /api/gifts/sent` | Gift (Presentation) | ❌ MISSING in Backend |
| 202 | `GET /api/gifts/received` | Gift (Presentation) | ❌ MISSING in Backend |
| 203 | `POST /api/gifts/send` | Gift (Presentation) | ✅ MATCH |
| 204 | `GET /api/gifts/ranking` | Gift (Presentation) | ❌ MISSING in Backend |
| 205 | `GET /api/gifts/:id` | Gift (Presentation) | ❌ MISSING in Backend |
| 206 | `GET /api/chat/conversations` | Chat (Presentation) | ❌ MISSING in Backend |
| 207 | `GET /api/chat/conversations/:id/messages` | Chat (Presentation) | ❌ MISSING in Backend |
| 208 | `POST /api/chat/conversations/:id/messages` | Chat (Presentation) | ❌ MISSING in Backend |
| 209 | `DELETE /api/chat/conversations/:id` | Chat (Presentation) | ❌ MISSING in Backend |
| 210 | `POST /api/chat/conversations/start` | Chat (Presentation) | ❌ MISSING in Backend |

---

## Overall Summary

| Metric | Count |
|---|---|
| **Total Flutter Endpoints (Active)** | ~120 |
| **Total Backend Routes** | ~60 |
| **Exact Matches** | ~15 |
| **Route Mismatches** | ~25 |
| **Flutter Endpoints Missing in Backend** | ~80 |
| **Backend Routes Not Used in Flutter** | ~45 |

**Key Findings:**

1. **Major Route Inconsistency**: Most Flutter endpoints use different route paths compared to what's defined in the backend. For example, Flutter uses `/auth/signup` while backend uses `/auth/register`.

2. **Auth Flow Mismatch**: Backend uses OTP-based authentication (send-otp, verify-otp, resend-otp), but Flutter implements direct signup/login with password change capability.

3. **Missing Modules**: Several backend modules (Admin, Staff, Agency, PK Battle, Family, CP, Treasury, Matchmaking, Rankings, Inventory, Creator, Referral, Support) have NO corresponding Flutter implementation.

4. **Missing Backend APIs**: Many Flutter features (Moments, Events, Lucky Draw, Search, Friend Requests system, Private Messages, Notifications, Block/Mute features) have NO backend implementation.

5. **Gift System**: The backend has `POST /api/wallet/send-gift` as a wallet-based gift endpoint, but Flutter uses `/gifts/send` - these may need integration.

6. **File Upload**: Flutter has `/messages/private/upload`, `/profile/avatar`, `/profile/cover` endpoints that are completely missing in backend.

7. **Friend System**: Backend has a minimal `GET /api/social/connections` and `POST /api/social/follow`, while Flutter has a full friend system (requests, followers, following, mutual) that is not implemented on the backend.

8. **Chat Backend Gap**: The backend only has `GET /api/chat/history/` while Flutter has full private messaging with typing indicators, read receipts, media upload, and message management.