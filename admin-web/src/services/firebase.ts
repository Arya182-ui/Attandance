import { initializeApp } from 'firebase/app';
import { getAuth } from 'firebase/auth';
import { getFirestore, enableMultiTabIndexedDbPersistence } from 'firebase/firestore';
import { getStorage } from 'firebase/storage';

// Firebase configuration - Use environment variables for production
// Falls back to hardcoded config for development if .env is not set
const firebaseConfig = {
  apiKey: import.meta.env.VITE_FIREBASE_API_KEY || "AIzaSyB5tYxpZdUQfvWbNYNb7m7eqxS7tKtLFBQ",
  authDomain: import.meta.env.VITE_FIREBASE_AUTH_DOMAIN || "attendance-tushar.firebaseapp.com",
  projectId: import.meta.env.VITE_FIREBASE_PROJECT_ID || "attendance-tushar",
  storageBucket: import.meta.env.VITE_FIREBASE_STORAGE_BUCKET || "attendance-tushar.firebasestorage.app",
  messagingSenderId: import.meta.env.VITE_FIREBASE_MESSAGING_SENDER_ID || "3016273431",
  appId: import.meta.env.VITE_FIREBASE_APP_ID || "1:3016273431:web:b9623f44e0a2382222b652"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);

// Secondary app for creating users without affecting admin session
const secondaryApp = initializeApp(firebaseConfig, 'secondary');

// Export Firebase services
export const auth = getAuth(app);
export const secondaryAuth = getAuth(secondaryApp);
export const db = getFirestore(app);
export const storage = getStorage(app);

// Enable offline persistence (production ready)
// This allows the app to work offline and sync when back online
try {
  if (typeof window !== 'undefined') {
    // Use multi-tab persistence in production for better UX
    enableMultiTabIndexedDbPersistence(db).catch((err) => {
      if (err.code === 'failed-precondition') {
        console.warn('Multiple tabs open, persistence enabled in first tab only');
      } else if (err.code === 'unimplemented') {
        console.warn('Browser does not support persistence');
      } else {
        console.error('Error enabling persistence:', err);
      }
    });
  }
} catch (err) {
  console.warn('Persistence not available:', err);
}

export default app;