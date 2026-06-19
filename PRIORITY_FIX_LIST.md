# ARVIND PARTY — PRIORITY FIX LIST

**Generated:** 2025-06-19  
**Ordered by:** Severity → Impact → Effort

---

## PRIORITY 1 — CRITICAL (Fix Before Production)

### P1-C-01: Add Rate Limiting to Auth Endpoints
- **File:** `arvind-party-backend/src/routes/auth.routes.js`
- **Issue:** No brute-force protection on OTP/login endpoints
- **Fix:** Install `express-rate-limit`, apply to `/auth/phone-login`, `/auth/otp-verify`, `/admin/auth/login`
- **Effort:** 1 hour

### P1-C-02: Add Missing Routes for New Models
- **Files:** `src/controllers/momentController.js`, `src/controllers/notificationController.js`, `src/controllers/eventController.js` + route files
- **Issue:** Models exist but no REST endpoints. Mobile UI calls `/api/moments/feed`, `/api/notifications`, `/api/events/list` — all 404
- **Fix:** Create controllers + wire routes in `appUserRoutes.js` or new route file
- **Effort:** 6–8 hours

### P1-C-03: Verify CORS Configuration
- **File:** `arvind-party-backend/src/app.js` or `config/cors.js`
- **Issue:** May allow all origins in production
- **Fix:** Restrict to `https://api.arvindparty.com`, `https://admin.arvindparty.com`, `http://192.168.1.100:5000` (dev)
- **Effort:** 30 minutes

### P1-C-04: Add MongoDB Connection Error Handling
- **File:** `arvind-party-backend/src/config/db.js` (or wherever Mongoose connects)
- **Issue:** If MongoDB drops, server crashes instead of retrying
- **Fix:** Add `mongoose.connection.on('error')` handler + exponential backoff reconnect
- **Effort:** 1 hour

---

## PRIORITY 2 — HIGH (Fix Before Launch)

### P2-H-01: Add Request Validation Middleware
- **Files:** All route files
- **Issue:** Controllers trust input without schema validation (except partial `validation.middleware.js`)
- **Fix:** Install `joi` or `zod`, add validation to all POST/PUT routes
- **Effort:** 4–6 hours

### P2-H-02: Structured Logging
- **File:** `arvind-party-backend/src/middlewares/` (new file)
- **Issue:** `console.log` only — no structured logs, no log levels, no output to file
- **Fix:** Install `winston` or `pino`, replace console calls, add log rotation
- **Effort:** 2–3 hours

### P2-H-03: Add Health Check Endpoint
- **File:** `arvind-party-backend/src/routes/` (new route or add to `appUserRoutes.js`)
- **Issue:** No `/health` endpoint for load balancer / monitoring
- **Fix:**
  ```javascript
  router.get('/health', (req, res) => {
    res.json({ status: 'ok', uptime: process.uptime(), mongo: mongoose.connection.readyState });
  });
  ```
- **Effort:** 15 minutes

### P2-H-04: Add Socket.io Authentication
- **File:** `arvind-party-backend/src/sockets/roomSocket.js`, `chatSocket.js`
- **Issue:** Any client can connect to socket namespace without token verification
- **Fix:** Add `socket.use((next) => { /* verify JWT from handshake */ })` middleware
- **Effort:** 2–3 hours

### P2-H-05: Environment Variable Validation at Startup
- **File:** `arvind-party-backend/server.js`
- **Issue:** Server starts even if `JWT_SECRET`, `MONGO_URI`, `PORT` missing
- **Fix:** Add startup check that exits with error if required env vars absent
- **Effort:** 30 minutes

### P2-H-06: Remove `.env` from Git Tracking
- **File:** `arvind-party-backend/.gitignore` (if not already)
- **Issue:** Secrets committed to repo history
- **Fix:** Add `.env` to `.gitignore`, rotate all exposed secrets
- **Effort:** 30 minutes + secret rotation

---

## PRIORITY 3 — MEDIUM (Post-Launch Improvements)

### P3-M-01: Add API Response Caching
- **Effort:** 4–6 hours
- **Benefit:** Reduce DB load for static/semi-static data (rankings, events, settings)

### P3-M-02: Add Redis for Session + Rate Limit State
- **Effort:** 4–6 hours
- **Benefit:** Share state across server instances, enable horizontal scaling

### P3-M-03: Add Docker + Docker Compose
- **Effort:** 4–6 hours
- **Benefit:** One-command deployment, consistent environments

### P3-M-04: Add CI/CD Pipeline
- **Effort:** 6–8 hours
- **Benefit:** Automated tests + deployment on push

### P3-M-05: Password Hashing for Staff/Admin
- **Effort:** 3–4 hours
- **Benefit:** Staff passwords currently unclear if hashed

### P3-M-06: Add Global Error Handling Middleware
- **Effort:** 2–3 hours
- **Benefit:** Consistent error responses, no stack traces to client

### P3-M-07: Add Request ID / Correlation ID
- **Effort:** 1–2 hours
- **Benefit:** Trace requests across logs

### P3-M-08: Add API Versioning Strategy
- **Effort:** 2–3 hours
- **Benefit:** Safe backend evolution without breaking clients

### P3-M-09: Add Unit + Integration Tests
- **Effort:** 10–15 hours
- **Benefit:** Regression safety net

### P3-M-10: Mobile Offline Storage
- **Effort:** 6–8 hours
- **Benefit:** App usable without network, better UX

---

## PRIORITY 4 — LOW (Nice-to-Have)

### P4-L-01: Add CDN for Static Assets
### P4-L-02: Add WebSocket Heartbeat / Ping-Pong
### P4-L-03: Add Admin Dashboard Charts/Graphs (use Chart.js or similar)
### P4-L-04: Add CSV/PDF Export for Reports
### P4-L-05: Add Multi-language Support (i18n)
### P4-L-06: Add Dark Mode to Web Panel
### P4-L-07: Add Push Notifications (FCM for mobile, web push for admin)
### P4-L-08: Add Performance Monitoring (APM like New Relic or Datadog)
### P4-L-09: Add Automated Database Backups
### P4-L-10: Add Feature Flags

---

## QUICK WINS (< 30 min each)

| # | Fix | File | Time |
|---|-----|------|------|
| QW-1 | Add `/health` endpoint | new route | 15m |
| QW-2 | Validate env vars at startup | server.js | 15m |
| QW-3 | Enforce HTTPS in production | app.js | 15m |
| QW-4 | Add `trust proxy` for rate limber | app.js | 5m |
| QW-5 | Remove unused `controllers/` and `views/` root dirs | root | 10m |
| QW-6 | Add `helmet` middleware | app.js | 10m |
| QW-7 | Add `xss-clean` middleware | app.js | 10m |
| QW-8 | Add MongoDB index on `createdAt` for all models | all models | 20m |

---

## EFFORT SUMMARY

| Priority | Total Hours | Blocking Production? |
|----------|------------|----------------------|
| P1 Critical | 9–11h | YES |
| P2 High | 14–19h | Recommended |
| P3 Medium | 42–63h | Post-launch |
| P4 Low | 20–30h | Optional |
| **Total** | **85–123h** | |

**Minimum to production-safe: ~25 hours** (P1 + QW only)

---

## CONNECTED vs DISCONNECTED SYSTEMS

| System | Status |
|--------|--------|
| Flutter Auth ↔ Backend Auth | ✅ Connected |
| Flutter Auth ↔ Web Admin Auth | ✅ Connected |
| Flutter ↔ Backend Room Socket | ✅ Connected |
| Flutter ↔ Backend Chat Socket | ✅ Connected |
| Flutter ↔ Backend Wallet API | ✅ Connected (but UI incomplete) |
| Web Admin ↔ Backend Dashboard | ✅ Connected |
| Web Admin ↔ Backend User Mgmt | ✅ Connected |
| Web Admin ↔ Backend Wallet Mgmt | ✅ Connected |
| Mobile Moments ↔ Backend | ❌ Disconnected (no routes) |
| Mobile Notifications ↔ Backend | ❌ Disconnected (no routes) |
| Mobile Events ↔ Backend | ❌ Disconnected (no routes) |
| Mobile Wallet Recharge UI ↔ Backend | ⚠️ Partial (API exists, UI missing) |