import { auth, db } from '../services/firebase';
import { createUserWithEmailAndPassword } from 'firebase/auth';
import { doc, setDoc, getDoc, collection, getDocs } from 'firebase/firestore';

export class FirebaseDebugger {
  // Test Firebase connection by checking auth state
  static async testConnection(): Promise<boolean> {
    try {
      // Test auth connection
      const authResult = auth.currentUser !== undefined;
      console.log('Auth connection test:', authResult ? 'SUCCESS' : 'FAILED');
      
      // Test Firestore connection
      try {
        await getDoc(doc(db, 'test', 'connection'));
        console.log('Firestore connection test: SUCCESS');
        return true;
      } catch (error) {
        console.error('Firestore connection test: FAILED', error);
        return false;
      }
    } catch (error) {
      console.error('Firebase connection test failed:', error);
      return false;
    }
  }

  // Check if admin users exist in the database
  static async checkAdminUsers(): Promise<any[]> {
    try {
      const usersCollection = collection(db, 'users');
      const querySnapshot = await getDocs(usersCollection);
      
      const adminUsers: any[] = [];
      querySnapshot.forEach((doc) => {
        const userData = doc.data();
        if (userData.role === 'admin' || userData.role === 'super_admin') {
          adminUsers.push({
            id: doc.id,
            ...userData
          });
        }
      });

      console.log('Admin users found:', adminUsers);
      return adminUsers;
    } catch (error) {
      console.error('Error checking admin users:', error);
      return [];
    }
  }

  // Create a demo admin user (for development only)
  static async createDemoAdmin(email: string = 'admin@test.com', password: string = 'admin123'): Promise<boolean> {
    try {
      console.log('Creating demo admin user:', email);
      
      // Create Firebase Auth user
      const userCredential = await createUserWithEmailAndPassword(auth, email, password);
      const user = userCredential.user;

      // Create user profile in Firestore
      await setDoc(doc(db, 'users', user.uid), {
        email: email,
        name: 'Demo Admin',
        role: 'admin',
        createdAt: new Date().toISOString(),
        isActive: true,
        phone: '',
        displayName: 'Demo Admin User'
      });

      console.log('Demo admin user created successfully:', user.uid);
      return true;
    } catch (error: any) {
      if (error.code === 'auth/email-already-in-use') {
        console.log('Admin user already exists, checking profile...');
        
        // Try to update the user profile if it exists
        try {
          const user = auth.currentUser;
          if (user) {
            await setDoc(doc(db, 'users', user.uid), {
              email: email,
              name: 'Demo Admin',
              role: 'admin',
              createdAt: new Date().toISOString(),
              isActive: true,
              phone: '',
              displayName: 'Demo Admin User'
            }, { merge: true });
            console.log('Admin user profile updated');
            return true;
          }
        } catch (updateError) {
          console.error('Error updating admin profile:', updateError);
        }
      }
      
      console.error('Error creating demo admin:', error);
      return false;
    }
  }

  // Get Firebase project info
  static getProjectInfo(): object {
    return {
      projectId: auth.app.options.projectId,
      authDomain: auth.app.options.authDomain,
      apiKey: auth.app.options.apiKey ? 'Set' : 'Missing',
      appId: auth.app.options.appId ? 'Set' : 'Missing'
    };
  }

  // Run comprehensive Firebase diagnostics
  static async runDiagnostics(): Promise<void> {
    console.log('🔍 Running Firebase Diagnostics...');
    console.log('================================');
    
    // 1. Project Info
    console.log('📋 Project Configuration:');
    console.log(this.getProjectInfo());
    console.log('');
    
    // 2. Connection Test
    console.log('🔗 Testing Firebase Connection...');
    const isConnected = await this.testConnection();
    console.log('Connection Status:', isConnected ? '✅ CONNECTED' : '❌ DISCONNECTED');
    console.log('');
    
    // 3. Check Admin Users
    console.log('👥 Checking Admin Users...');
    const adminUsers = await this.checkAdminUsers();
    
    if (adminUsers.length === 0) {
      console.log('⚠️ No admin users found in database!');
      console.log('💡 To create a demo admin user, run:');
      console.log('   FirebaseDebugger.createDemoAdmin()');
      console.log('');
      console.log('🔧 Manual Setup Instructions:');
      console.log('1. Go to Firebase Console > Authentication');
      console.log('2. Create user with email: admin@test.com, password: admin123');
      console.log('3. Go to Firestore Database');
      console.log('4. Create document in "users" collection with:');
      console.log('   - Document ID: [user-uid]');
      console.log('   - Fields: { email: "admin@test.com", role: "admin", name: "Admin User" }');
    } else {
      console.log('✅ Admin users found:', adminUsers.length);
      adminUsers.forEach((user, index) => {
        console.log(`${index + 1}. ${user.email} (${user.role})`);
      });
    }
    
    console.log('================================');
    console.log('📊 Diagnostics Complete');
  }
}

// Make it available globally for easy debugging
if (typeof window !== 'undefined') {
  (window as any).FirebaseDebugger = FirebaseDebugger;
}

export default FirebaseDebugger;