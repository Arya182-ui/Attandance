import { create } from 'zustand';
import { authService } from '../services/auth';
import type { AuthUser, LoginCredentials } from '../types';

interface AuthState {
  user: AuthUser | null;
  isLoading: boolean;
  error: string | null;
  isInitialized: boolean;
}

interface AuthActions {
  signIn: (credentials: LoginCredentials) => Promise<void>;
  signOut: () => Promise<void>;
  initializeAuth: () => void;
  clearError: () => void;
}

type AuthStore = AuthState & AuthActions;

export const useAuthStore = create<AuthStore>((set) => ({
  // Initial state
  user: null,
  isLoading: false,
  error: null,
  isInitialized: false,

  // Actions
  signIn: async (credentials: LoginCredentials) => {
    set({ isLoading: true, error: null });
    
    try {
      const user = await authService.signIn(credentials);
      set({ user, isLoading: false });
    } catch (error: any) {
      set({ 
        error: error.message || 'Authentication failed', 
        isLoading: false 
      });
      throw error;
    }
  },

  signOut: async () => {
    set({ isLoading: true });
    
    try {
      await authService.signOut();
      set({ user: null, isLoading: false, error: null });
    } catch (error: any) {
      set({ 
        error: error.message || 'Sign out failed', 
        isLoading: false 
      });
    }
  },

  initializeAuth: () => {
    set({ isLoading: true });
    
    // Subscribe to auth state changes
    const unsubscribe = authService.onAuthStateChange((user) => {
      set({ 
        user, 
        isLoading: false, 
        isInitialized: true,
        error: null 
      });
    });

    // Return cleanup function (though we don't store it in this simple example)
    return unsubscribe;
  },

  clearError: () => {
    set({ error: null });
  },
}));

// Derived state selectors
export const useAuthState = () => {
  const { user, isLoading, error, isInitialized } = useAuthStore();
  return {
    user,
    isLoading,
    error,
    isInitialized,
    isAuthenticated: !!user,
  };
};