import { 
  doc, 
  getDoc, 
  setDoc, 
  updateDoc,
  serverTimestamp 
} from 'firebase/firestore';
import { db } from './firebase';
import type { Institute } from '../types';

class InstituteService {
  private readonly docId = 'settings'; // Single settings document

  // Get institute settings
  async getInstituteSettings(): Promise<Institute | null> {
    try {
      const docRef = doc(db, 'institute', this.docId);
      const docSnap = await getDoc(docRef);
      
      if (docSnap.exists()) {
        const data = docSnap.data();
        return {
          id: docSnap.id,
          name: data.name || 'Institute',
          address: data.address || '',
          location: data.latitude && data.longitude ? {
            latitude: data.latitude,
            longitude: data.longitude
          } : undefined,
          allowedRadius: data.allowedRadius || data.radius || 100, // Support both field names
          adminEmails: data.adminEmails || [],
          createdAt: data.createdAt?.toDate() || new Date(),
          updatedAt: data.updatedAt?.toDate() || new Date()
        };
      }
      
      return null;
    } catch (error) {
      console.error('Error getting institute settings:', error);
      throw new Error('Failed to load institute settings');
    }
  }

  // Save institute settings
  async saveInstituteSettings(settings: Omit<Institute, 'id' | 'createdAt' | 'updatedAt'>): Promise<void> {
    try {
      const docRef = doc(db, 'institute', this.docId);
      
      // Check if document exists
      const docSnap = await getDoc(docRef);
      
      const settingsData = {
        name: settings.name || 'Institute',
        address: settings.address || '',
        latitude: settings.location?.latitude || null,
        longitude: settings.location?.longitude || null,
        allowedRadius: settings.allowedRadius || 100,
        radius: settings.allowedRadius || 100, // Keep both for compatibility
        adminEmails: settings.adminEmails || [],
        updatedAt: serverTimestamp()
      };

      if (docSnap.exists()) {
        // Update existing settings
        await updateDoc(docRef, settingsData);
      } else {
        // Create new settings
        await setDoc(docRef, {
          ...settingsData,
          createdAt: serverTimestamp()
        });
      }
    } catch (error) {
      console.error('Error saving institute settings:', error);
      throw new Error('Failed to save institute settings');
    }
  }

  // Get current location settings for validation
  async getLocationSettings(): Promise<{ latitude: number; longitude: number; radius: number } | null> {
    try {
      const settings = await this.getInstituteSettings();
      
      if (settings?.location) {
        return {
          latitude: settings.location.latitude,
          longitude: settings.location.longitude,
          radius: settings.allowedRadius
        };
      }
      
      return null;
    } catch (error) {
      console.error('Error getting location settings:', error);
      throw new Error('Failed to get location settings');
    }
  }

  // Update only location settings
  async updateLocationSettings(latitude: number, longitude: number, radius?: number): Promise<void> {
    try {
      const docRef = doc(db, 'institute', this.docId);
      
      const updateData: any = {
        latitude,
        longitude,
        updatedAt: serverTimestamp()
      };

      if (radius !== undefined) {
        updateData.allowedRadius = radius;
        updateData.radius = radius; // Keep both for compatibility
      }

      await updateDoc(docRef, updateData);
    } catch (error) {
      console.error('Error updating location settings:', error);
      throw new Error('Failed to update location settings');
    }
  }

  // Validate if a location is within allowed radius
  async validateLocation(userLatitude: number, userLongitude: number): Promise<{
    isValid: boolean;
    distance: number;
    allowedRadius: number;
  }> {
    try {
      const settings = await this.getLocationSettings();
      
      if (!settings) {
        throw new Error('Institute location not configured');
      }

      // Calculate distance using Haversine formula
      const distance = this.calculateDistance(
        settings.latitude,
        settings.longitude,
        userLatitude,
        userLongitude
      );

      return {
        isValid: distance <= settings.radius,
        distance,
        allowedRadius: settings.radius
      };
    } catch (error) {
      console.error('Error validating location:', error);
      throw error;
    }
  }

  // Calculate distance between two coordinates using Haversine formula
  private calculateDistance(lat1: number, lon1: number, lat2: number, lon2: number): number {
    const R = 6371e3; // Earth's radius in meters
    const φ1 = lat1 * Math.PI / 180;
    const φ2 = lat2 * Math.PI / 180;
    const Δφ = (lat2 - lat1) * Math.PI / 180;
    const Δλ = (lon2 - lon1) * Math.PI / 180;

    const a = Math.sin(Δφ/2) * Math.sin(Δφ/2) +
              Math.cos(φ1) * Math.cos(φ2) *
              Math.sin(Δλ/2) * Math.sin(Δλ/2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));

    return R * c; // Distance in meters
  }
}

export const instituteService = new InstituteService();