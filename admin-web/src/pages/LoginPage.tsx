import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { Eye, EyeOff, LogIn, AlertCircle, GraduationCap } from 'lucide-react';
import { useAuthStore } from '../stores/auth';
import type { LoginCredentials } from '../types';

const loginSchema = z.object({
  email: z.string().email('Please enter a valid email address'),
  password: z.string().min(1, 'Password is required'),
});

type LoginFormData = z.infer<typeof loginSchema>;

export default function LoginPage() {
  const [showPassword, setShowPassword] = useState(false);
  const { signIn, error, isLoading, clearError } = useAuthStore();
  const navigate = useNavigate();

  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm<LoginFormData>({
    resolver: zodResolver(loginSchema),
  });

  const onSubmit = async (data: LoginFormData) => {
    clearError();
    try {
      await signIn(data as LoginCredentials);
      // Redirect to dashboard after successful login
      navigate('/', { replace: true });
    } catch (error) {
      // Error is handled by the store
    }
  };


  return (
    <div className="min-h-screen flex items-center justify-center bg-linear-to-br from-teal-50 via-blue-50 to-cyan-50 py-12 px-4 sm:px-6 lg:px-8">
      <div className="absolute inset-0 bg-white/60 backdrop-blur-3xl"></div>
      <div className="relative max-w-md w-full space-y-8">
        {/* Header */}
        <div className="text-center">
          <div className="mx-auto h-20 w-20 bg-linear-to-br from-teal-600 to-blue-700 rounded-2xl flex items-center justify-center mb-6 shadow-xl">
            <GraduationCap className="h-10 w-10 text-white" />
          </div>
          <h2 className="text-3xl font-bold bg-linear-to-r from-teal-600 to-blue-700 bg-clip-text text-transparent">
            SmartCareerAdvisor
          </h2>
          <p className="mt-2 text-base text-gray-600">
            Attendance Management System
          </p>
          <p className="mt-1 text-sm text-gray-400">
            Expert Career Guidance & Professional Development
          </p>
          <div className="mt-4 flex items-center justify-center space-x-2">
            <div className="h-1 w-8 bg-teal-600 rounded"></div>
            <div className="h-1 w-4 bg-blue-400 rounded"></div>
            <div className="h-1 w-2 bg-cyan-400 rounded"></div>
          </div>
        </div>

        {/* Login Form */}
        <div className="bg-white/80 backdrop-blur-sm rounded-2xl shadow-2xl border border-white/20 p-8">
          <form className="space-y-6" onSubmit={handleSubmit(onSubmit)}>
            {/* Email Field */}
            <div>
              <label htmlFor="email" className="block text-sm font-medium text-gray-700 mb-2">
                Email Address
              </label>
              <input
                {...register('email')}
                type="email"
                autoComplete="email"
                className={`input-field ${errors.email ? 'border-red-300 focus:border-red-500 focus:ring-red-500' : ''}`}
                placeholder="Enter your email"
              />
              {errors.email && (
                <p className="mt-1 text-sm text-red-600 flex items-center gap-1">
                  <AlertCircle className="h-4 w-4" />
                  {errors.email.message}
                </p>
              )}
            </div>

            {/* Password Field */}
            <div>
              <label htmlFor="password" className="block text-sm font-medium text-gray-700 mb-2">
                Password
              </label>
              <div className="relative">
                <input
                  {...register('password')}
                  type={showPassword ? 'text' : 'password'}
                  autoComplete="current-password"
                  className={`input-field pr-10 ${errors.password ? 'border-red-300 focus:border-red-500 focus:ring-red-500' : ''}`}
                  placeholder="Enter your password"
                />
                <button
                  type="button"
                  className="absolute inset-y-0 right-0 pr-3 flex items-center"
                  onClick={() => setShowPassword(!showPassword)}
                >
                  {showPassword ? (
                    <EyeOff className="h-5 w-5 text-gray-400 hover:text-gray-600" />
                  ) : (
                    <Eye className="h-5 w-5 text-gray-400 hover:text-gray-600" />
                  )}
                </button>
              </div>
              {errors.password && (
                <p className="mt-1 text-sm text-red-600 flex items-center gap-1">
                  <AlertCircle className="h-4 w-4" />
                  {errors.password.message}
                </p>
              )}
            </div>

            {/* Error Message */}
            {error && (
              <div className="bg-red-50 border-l-4 border-red-400 rounded-lg p-4">
                <div className="flex">
                  <AlertCircle className="h-5 w-5 text-red-400 mr-3 mt-0.5 shrink-0" />
                  <div>
                    <h3 className="text-sm font-semibold text-red-800">
                      Authentication Failed
                    </h3>
                    <p className="text-sm text-red-700 mt-1">{error}</p>
                    {error.includes('User profile not found') && (
                      <div className="mt-3 p-3 bg-yellow-50 border border-yellow-200 rounded text-xs text-yellow-800">
                        <p className="font-semibold">First-time setup:</p>
                        <p>Create an admin user in Firestore with role: 'admin'</p>
                      </div>
                    )}
                  </div>
                </div>
              </div>
            )}

            {/* Submit Button */}
            <button
              type="submit"
              disabled={isLoading}
              className={`group w-full flex justify-center items-center gap-2 py-3 px-4 border border-transparent text-sm font-semibold rounded-xl text-white bg-linear-to-r from-teal-600 to-blue-700 hover:from-teal-700 hover:to-blue-800 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-teal-500 disabled:opacity-50 disabled:cursor-not-allowed transition-all duration-300 transform hover:scale-105 disabled:hover:scale-100 shadow-lg hover:shadow-xl ${
                isLoading ? 'cursor-not-allowed' : ''
              }`}
            >
              {isLoading ? (
                <>
                  <div className="animate-spin rounded-full h-5 w-5 border-2 border-white border-t-transparent"></div>
                  <span>Signing in...</span>
                </>
              ) : (
                <>
                  <LogIn className="h-5 w-5 group-hover:rotate-3 transition-transform duration-200" />
                  <span>Sign In to Dashboard</span>
                </>
              )}
            </button>
          </form>

          {/* Additional Info */}
          <div className="mt-6 text-center space-y-3">
            <p className="text-sm text-gray-600 font-medium">
              🔐 Secure Admin Access Only
            </p>
            <div className="flex items-center justify-center space-x-4 text-xs text-gray-500">
              <span className="flex items-center">
                <div className="w-2 h-2 bg-green-400 rounded-full mr-2 animate-pulse"></div>
                Firebase Connected
              </span>
              <span className="flex items-center">
                <div className="w-2 h-2 bg-blue-400 rounded-full mr-2 animate-pulse"></div>
                Secure Authentication
              </span>
            </div>
          </div>
        </div>

        {/* Footer */}
        <div className="text-center space-y-2">
          <p className="text-sm font-medium text-gray-700">
            SmartCareerAdvisor
          </p>
          <p className="text-xs text-gray-500">
            &copy; {new Date().getFullYear()} SmartCareerAdvisor. All rights reserved.
          </p>
          <p className="text-xs text-gray-400">
            <a href="https://www.smartcareeradvisor.com" target="_blank" rel="noopener noreferrer" className="hover:text-teal-600 transition-colors">
              www.smartcareeradvisor.com
            </a>
          </p>
        </div>
      </div>
    </div>
  );
}