// ═══════════════════════════════════════════════════════════════════════════
// CONFIG: Firebase Admin SDK Initialization
// ═══════════════════════════════════════════════════════════════════════════

const admin = require('firebase-admin');

let initialized = false;

function initFirebaseAdmin() {
  if (initialized) return admin;

  try {
    const projectId = process.env.FIREBASE_PROJECT_ID;
    const clientEmail = process.env.FIREBASE_CLIENT_EMAIL;
    let privateKey = process.env.FIREBASE_PRIVATE_KEY;

    if (!projectId || !clientEmail || !privateKey) {
      console.warn('⚠️  Firebase Admin not configured. Set FIREBASE_PROJECT_ID, FIREBASE_CLIENT_EMAIL, FIREBASE_PRIVATE_KEY in .env');
      return null;
    }

    // Handle escaped newlines in .env
    privateKey = privateKey.replace(/\\n/g, '\n');

    admin.initializeApp({
      credential: admin.credential.cert({
        projectId,
        clientEmail,
        privateKey,
      }),
      databaseURL: process.env.FIREBASE_DATABASE_URL,
    });

    initialized = true;
    console.log('✅ Firebase Admin initialized');
    return admin;
  } catch (err) {
    console.error('❌ Firebase Admin init failed:', err.message);
    return null;
  }
}

module.exports = { initFirebaseAdmin, admin };
