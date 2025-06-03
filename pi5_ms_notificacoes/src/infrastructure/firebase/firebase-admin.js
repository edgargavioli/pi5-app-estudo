import admin from 'firebase-admin';

const path = process.env.FIREBASE;

let firebaseAdminInitialized = false;

export default function initializeFirebaseAdmin() {
    if (firebaseAdminInitialized) {
        return;
    };

    try {
        const serviceAccount = require(path);

        admin.initializeApp({
            credential: admin.credential.cert(serviceAccount),
        });

        console.log('Firebase Admin SDK initialized successfully.');
        firebaseAdminInitialized = true;
        return admin;
    } catch (error) {
        console.error('Error initializing Firebase Admin SDK:', error);
        throw error;
    }
}