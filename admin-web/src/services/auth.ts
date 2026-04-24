import { 
  signInWithEmailAndPassword, 
  signOut as firebaseSignOut,
  onAuthStateChanged,
  createUserWithEmailAndPassword,
  signOut
} from 'firebase/auth';
import { doc, getDoc } from 'firebase/firestore';
import { auth, secondaryAuth, db } from './firebase';
import type { AuthUser, LoginCredentials } from '../types';

class AuthService {
  // Sign in with email and password
  async signIn({ email, password }: LoginCredentials): Promise<AuthUser> {
    try {
      const userCredential = await signInWithEmailAndPassword(auth, email, password);
      const user = userCredential.user;
      
      // Get additional user data from Firestore
      const userDoc = await getDoc(doc(db, 'users', user.uid));
      
      if (!userDoc.exists()) {
        // If no user profile found, create admin profile for first-time setup
        console.warn('User profile not found. Creating admin profile for:', user.email);
        
        // For now, allow login and create basic admin profile
        return {
          id: user.uid,
          email: user.email || '',
          name: user.email?.split('@')[0] || 'Admin User',
          role: 'admin'
        };
      }
      
      const userData = userDoc.data();
      
      // Check if user is admin
      if (userData.role !== 'admin' && userData.role !== 'super_admin') {
        await firebaseSignOut(auth);
        throw new Error('Access denied. Only administrators can access this panel.');
      }
      
      return {
        id: user.uid,
        email: user.email || '',
        name: userData.name || userData.displayName || user.email?.split('@')[0] || 'Admin User',
        role: userData.role || 'admin'
      };
    } catch (error: any) {
      console.error('Sign in error:', error);
      
      // Provide more helpful error messages
      if (error.code === 'auth/network-request-failed') {
        throw new Error('Network error. Please check your internet connection and try again.');
      }
      if (error.code === 'auth/too-many-requests') {
        throw new Error('Too many failed attempts. Please wait a few minutes and try again.');
      }
      
      throw new Error(this.getAuthErrorMessage(error.code) || error.message);
    }
  }
  
  // Create new user (for admins creating students)
  // Uses secondary auth instance so admin session is untouched
  async createUser({ email, password }: { email: string; password: string }): Promise<string> {
    try {
      // Create on secondary auth — admin stays logged in on primary auth
      const userCredential = await createUserWithEmailAndPassword(secondaryAuth, email, password);
      const newUserUid = userCredential.user.uid;
      
      // Sign out from secondary auth (cleanup)
      await signOut(secondaryAuth);
      
      return newUserUid;
    } catch (error: any) {
      console.error('Create user error:', error);
      throw new Error(this.getAuthErrorMessage(error.code) || 'Failed to create user account');
    }
  }

  // Sign out
  async signOut(): Promise<void> {
    try {
      await firebaseSignOut(auth);
    } catch (error: any) {
      console.error('Sign out error:', error);
      throw new Error('Failed to sign out');
    }
  }
  
  // Get current user
  getCurrentUser(): Promise<AuthUser | null> {
    return new Promise((resolve) => {
      const unsubscribe = onAuthStateChanged(auth, async (firebaseUser) => {
        unsubscribe();
        
        if (!firebaseUser) {
          resolve(null);
          return;
        }
        
        try {
          // Get user data from Firestore
          const userDoc = await getDoc(doc(db, 'users', firebaseUser.uid));
          
          if (!userDoc.exists()) {
            resolve(null);
            return;
          }
          
          const userData = userDoc.data();
          
          // Only allow admin users
          if (userData.role !== 'admin' && userData.role !== 'super_admin') {
            await firebaseSignOut(auth);
            resolve(null);
            return;
          }
          
          resolve({
            id: firebaseUser.uid,
            email: firebaseUser.email || '',
            name: userData.name || firebaseUser.email?.split('@')[0] || '',
            role: userData.role
          });
        } catch (error) {
          console.error('Error getting user data:', error);
          resolve(null);
        }
      });
    });
  }
  
  // Subscribe to auth state changes
  onAuthStateChange(callback: (user: AuthUser | null) => void): () => void {
    return onAuthStateChanged(auth, async (firebaseUser) => {
      if (!firebaseUser) {
        callback(null);
        return;
      }
      
      try {
        // Get user data from Firestore
        const userDoc = await getDoc(doc(db, 'users', firebaseUser.uid));
        
        if (!userDoc.exists()) {
          callback(null);
          return;
        }
        
        const userData = userDoc.data();
        
        // Only allow admin users
        if (userData.role !== 'admin' && userData.role !== 'super_admin') {
          await firebaseSignOut(auth);
          callback(null);
          return;
        }
        
        callback({
          id: firebaseUser.uid,
          email: firebaseUser.email || '',
          name: userData.name || firebaseUser.email?.split('@')[0] || '',
          role: userData.role
        });
      } catch (error) {
        console.error('Error in auth state change:', error);
        callback(null);
      }
    });
  }
  
  private getAuthErrorMessage(errorCode: string): string {
    switch (errorCode) {
      case 'auth/user-not-found':
        return 'No account found with this email';
      case 'auth/wrong-password':
        return 'Incorrect password';
      case 'auth/invalid-email':
        return 'Invalid email address';
      case 'auth/too-many-requests':
        return 'Too many failed attempts. Please try again later';
      case 'auth/network-request-failed':
        return 'Network error. Please check your connection';
      case 'auth/invalid-credential':
        return 'Invalid email or password';
      default:
        return 'Authentication failed';
    }
  }
}

export const authService = new AuthService();