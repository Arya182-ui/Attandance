import { useState, useEffect } from 'react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { 
  MapPin, 
  Globe, 
  Save,
  RefreshCw,
  AlertCircle,
  CheckCircle
} from 'lucide-react';
import { instituteService } from '../services/institute';

const instituteSchema = z.object({
  name: z.string().optional(),
  address: z.string().optional(),
  latitude: z.number().min(-90).max(90).optional(),
  longitude: z.number().min(-180).max(180).optional(),
  allowedRadius: z.number().min(1, 'Radius must be at least 1 meter').max(10000, 'Radius cannot exceed 10km'),
});

type InstituteFormData = z.infer<typeof instituteSchema>;

export default function SettingsPage() {
  const [isLoading, setIsLoading] = useState(false);
  const [isSaving, setIsSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);
  const [locationStatus, setLocationStatus] = useState<'idle' | 'detecting' | 'success' | 'error'>('idle');

  const {
    register,
    handleSubmit,
    setValue,
    watch,
    formState: { errors, isDirty },
  } = useForm<InstituteFormData>({
    resolver: zodResolver(instituteSchema),
    defaultValues: {
      name: '',
      address: '',
      allowedRadius: 100,
    },
  });

  const watchedLatitude = watch('latitude');
  const watchedLongitude = watch('longitude');

  const loadInstituteSettings = async () => {
    try {
      setIsLoading(true);
      setError(null);
      
      const instituteSettings = await instituteService.getInstituteSettings();
      
      if (instituteSettings) {
        // Populate form with existing data
        if (instituteSettings.name) setValue('name', instituteSettings.name);
        if (instituteSettings.address) setValue('address', instituteSettings.address);
        if (instituteSettings.location) {
          setValue('latitude', instituteSettings.location.latitude);
          setValue('longitude', instituteSettings.location.longitude);
        }
        setValue('allowedRadius', instituteSettings.allowedRadius);
      } else {
        // Set default values for new setup
        setValue('allowedRadius', 100);
      }
      
    } catch (err: any) {
      setError(err.message || 'Failed to load institute settings');
    } finally {
      setIsLoading(false);
    }
  };

  const detectCurrentLocation = () => {
    if (!navigator.geolocation) {
      setError('Geolocation is not supported by this browser');
      return;
    }

    setLocationStatus('detecting');
    setError(null);

    navigator.geolocation.getCurrentPosition(
      (position) => {
        setValue('latitude', position.coords.latitude, { shouldDirty: true });
        setValue('longitude', position.coords.longitude, { shouldDirty: true });
        setLocationStatus('success');
        setSuccess('Location detected successfully');
        setTimeout(() => setSuccess(null), 3000);
      },
      (error) => {
        setLocationStatus('error');
        setError('Failed to get current location: ' + error.message);
      },
      {
        enableHighAccuracy: true,
        timeout: 10000,
        maximumAge: 0
      }
    );
  };

  const onSubmit = async (data: InstituteFormData) => {
    try {
      setIsSaving(true);
      setError(null);

      const instituteData = {
        name: data.name || '',
        address: data.address || '',
        allowedRadius: data.allowedRadius,
        adminEmails: [],
        location: data.latitude !== undefined && data.longitude !== undefined ? {
          latitude: data.latitude,
          longitude: data.longitude
        } : undefined,
      };

      await instituteService.saveInstituteSettings(instituteData);
      
      setSuccess('Institute settings saved successfully');
      setTimeout(() => setSuccess(null), 3000);
      
    } catch (err: any) {
      setError(err.message || 'Failed to save institute settings');
    } finally {
      setIsSaving(false);
    }
  };

  useEffect(() => {
    loadInstituteSettings();
  }, []);

  useEffect(() => {
    if (locationStatus === 'success') {
      const timer = setTimeout(() => setLocationStatus('idle'), 2000);
      return () => clearTimeout(timer);
    }
  }, [locationStatus]);

  if (isLoading) {
    return (
      <div className="flex items-center justify-center min-h-100">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-teal-600"></div>
        <span className="ml-3 text-gray-600">Loading settings...</span>
      </div>
    );
  }

  return (
    <div className="max-w-3xl mx-auto space-y-6">
      {/* Page Header */}
      <div>
        <h1 className="text-2xl font-bold text-gray-900">Settings</h1>
        <p className="mt-1 text-sm text-gray-500">
          Configure geo-fence location for attendance tracking
        </p>
      </div>

      {/* Success Message */}
      {success && (
        <div className="flex items-center gap-3 p-4 bg-emerald-50 border border-emerald-100 rounded-xl">
          <CheckCircle className="h-5 w-5 text-emerald-500 shrink-0" />
          <p className="text-sm text-emerald-700 font-medium">{success}</p>
        </div>
      )}

      {/* Error Message */}
      {error && (
        <div className="flex items-center gap-3 p-4 bg-red-50 border border-red-100 rounded-xl">
          <AlertCircle className="h-5 w-5 text-red-500 shrink-0" />
          <p className="text-sm text-red-700">{error}</p>
        </div>
      )}

      <form onSubmit={handleSubmit(onSubmit)} className="space-y-6">
        {/* Geo-Location Settings */}
        <div className="bg-white rounded-2xl p-6 border border-gray-100 shadow-sm">
          <div className="flex items-center justify-between mb-6">
            <div className="flex items-center gap-3">
              <div className="p-2.5 rounded-xl bg-teal-50">
                <MapPin className="h-5 w-5 text-teal-600" />
              </div>
              <div>
                <h2 className="text-base font-semibold text-gray-900">Geo-Location Settings</h2>
                <p className="text-sm text-gray-500">Set the center point and radius for attendance</p>
              </div>
            </div>
            <button
              type="button"
              onClick={detectCurrentLocation}
              disabled={locationStatus === 'detecting'}
              className="inline-flex items-center px-4 py-2.5 text-sm font-medium text-gray-700 bg-white border border-gray-200 rounded-xl hover:bg-gray-50 hover:border-gray-300 transition-all duration-200"
            >
              {locationStatus === 'detecting' ? (
                <>
                  <div className="animate-spin rounded-full h-4 w-4 border-2 border-teal-600 border-t-transparent mr-2"></div>
                  Detecting...
                </>
              ) : locationStatus === 'success' ? (
                <>
                  <CheckCircle className="h-4 w-4 text-emerald-500 mr-2" />
                  Done
                </>
              ) : (
                <>
                  <Globe className="h-4 w-4 mr-2" />
                  Detect My Location
                </>
              )}
            </button>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1.5">
                Latitude
              </label>
              <input
                {...register('latitude', { valueAsNumber: true })}
                type="number"
                step="any"
                className={`w-full px-4 py-2.5 border rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-500 transition-all ${errors.latitude ? 'border-red-300' : 'border-gray-200'}`}
                placeholder="e.g., 28.6139"
              />
              {errors.latitude && (
                <p className="mt-1 text-xs text-red-500">{errors.latitude.message}</p>
              )}
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1.5">
                Longitude
              </label>
              <input
                {...register('longitude', { valueAsNumber: true })}
                type="number"
                step="any"
                className={`w-full px-4 py-2.5 border rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-500 transition-all ${errors.longitude ? 'border-red-300' : 'border-gray-200'}`}
                placeholder="e.g., 77.2090"
              />
              {errors.longitude && (
                <p className="mt-1 text-xs text-red-500">{errors.longitude.message}</p>
              )}
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1.5">
                Allowed Radius (meters)
              </label>
              <input
                {...register('allowedRadius', { valueAsNumber: true })}
                type="number"
                min="1"
                max="10000"
                className={`w-full px-4 py-2.5 border rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-500 transition-all ${errors.allowedRadius ? 'border-red-300' : 'border-gray-200'}`}
                placeholder="100"
              />
              {errors.allowedRadius && (
                <p className="mt-1 text-xs text-red-500">{errors.allowedRadius.message}</p>
              )}
            </div>
          </div>

          {watchedLatitude && watchedLongitude && (
            <div className="mt-4 p-4 bg-blue-50/70 rounded-xl border border-blue-100">
              <p className="text-sm text-blue-800 font-medium">
                Location: {watchedLatitude.toFixed(6)}, {watchedLongitude.toFixed(6)}
              </p>
              <p className="text-xs text-blue-600 mt-1">
                Students must be within {watch('allowedRadius')}m of this location to mark attendance
              </p>
            </div>
          )}
        </div>

        {/* Save Button */}
        <div className="flex justify-end gap-3">
          <button
            type="button"
            onClick={loadInstituteSettings}
            className="px-4 py-2.5 text-sm font-medium text-gray-700 bg-gray-100 hover:bg-gray-200 rounded-xl transition-colors"
          >
            <RefreshCw className="h-4 w-4 mr-2 inline" />
            Reset
          </button>
          <button
            type="submit"
            disabled={isSaving || !isDirty}
            className={`px-5 py-2.5 text-sm font-medium text-white bg-teal-600 hover:bg-teal-700 rounded-xl transition-colors flex items-center gap-2 ${
              (!isDirty || isSaving) ? 'opacity-50 cursor-not-allowed' : ''
            }`}
          >
            {isSaving ? (
              <>
                <div className="animate-spin rounded-full h-4 w-4 border-2 border-white border-t-transparent"></div>
                Saving...
              </>
            ) : (
              <>
                <Save className="h-4 w-4" />
                Save Settings
              </>
            )}
          </button>
        </div>
      </form>
    </div>
  );
}