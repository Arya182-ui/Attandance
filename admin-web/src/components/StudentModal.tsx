import { useState, useEffect } from 'react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { X, Save, User, Eye, EyeOff, AlertCircle, Mail, Lock } from 'lucide-react';
import type { Student } from '../types';
import { studentService } from '../services/students';

// Simple schema - only name, email required. Password required for new students.
const studentSchema = z.object({
  name: z.string().min(2, 'Name must be at least 2 characters'),
  email: z.string().email('Please enter a valid email'),
  password: z.string().optional(),
  enrollmentNumber: z.string().optional(),
  course: z.string().optional(),
  batch: z.string().optional(),
  phone: z.string().optional(),
});

type StudentFormData = z.infer<typeof studentSchema>;

interface StudentModalProps {
  isOpen: boolean;
  onClose: () => void;
  onSave: () => void;
  student?: Student | null;
}

export default function StudentModal({ isOpen, onClose, onSave, student }: StudentModalProps) {
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [showPassword, setShowPassword] = useState(false);
  const [showOptional, setShowOptional] = useState(false);

  const {
    register,
    handleSubmit,
    reset,
    formState: { errors },
  } = useForm<StudentFormData>({
    resolver: zodResolver(studentSchema),
  });

  // Reset form when modal opens/closes
  useEffect(() => {
    if (isOpen) {
      if (student) {
        reset({
          name: student.name,
          email: student.email,
          password: '',
          enrollmentNumber: student.enrollmentNumber || '',
          course: student.course || '',
          batch: student.batch || '',
          phone: (student as any).phone || '',
        });
        setShowOptional(!!student.enrollmentNumber || !!student.course || !!student.batch);
      } else {
        reset({
          name: '',
          email: '',
          password: '',
          enrollmentNumber: '',
          course: '',
          batch: '',
          phone: '',
        });
        setShowOptional(false);
      }
      setError(null);
      setShowPassword(false);
    }
  }, [isOpen, student, reset]);

  const onSubmit = async (data: StudentFormData) => {
    // For new student, password is required
    if (!student && (!data.password || data.password.length < 6)) {
      setError('Password is required (minimum 6 characters) for new students');
      return;
    }

    setIsLoading(true);
    setError(null);

    try {
      if (student) {
        // Update existing student
        const updateData: any = {
          name: data.name,
          email: data.email,
          role: 'student',
        };
        if (data.enrollmentNumber) updateData.enrollmentNumber = data.enrollmentNumber;
        if (data.course) updateData.course = data.course;
        if (data.batch) updateData.batch = data.batch;
        if (data.phone) updateData.phone = data.phone;

        await studentService.updateStudent(student.id, updateData);
      } else {
        // Create new student in Firestore
        const studentData: any = {
          name: data.name,
          email: data.email,
          role: 'student',
          enrollmentNumber: data.enrollmentNumber || '',
          course: data.course || '',
          batch: data.batch || '',
          phone: data.phone || '',
          tempPassword: data.password, // Store temp password so student can login
        };

        await studentService.addStudent(studentData);
      }
      
      onSave();
      onClose();
    } catch (err: any) {
      setError(err.message || 'Failed to save student');
    } finally {
      setIsLoading(false);
    }
  };

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 bg-black/40 backdrop-blur-sm z-50 flex items-center justify-center p-4" onClick={onClose}>
      <div 
        className="bg-white rounded-2xl shadow-2xl w-full max-w-lg overflow-hidden"
        onClick={(e) => e.stopPropagation()}
      >
        {/* Header */}
        <div className="flex items-center justify-between px-6 py-5 border-b border-gray-100">
          <div>
            <h2 className="text-lg font-semibold text-gray-900">
              {student ? 'Edit Student' : 'Add New Student'}
            </h2>
            <p className="text-sm text-gray-500 mt-0.5">
              {student ? 'Update student details' : 'Fill in name, email & password to get started'}
            </p>
          </div>
          <button
            onClick={onClose}
            className="p-2 hover:bg-gray-100 rounded-lg transition-colors"
          >
            <X className="h-5 w-5 text-gray-400" />
          </button>
        </div>

        {/* Body */}
        <div className="p-6 overflow-y-auto max-h-[calc(90vh-140px)]">
          {error && (
            <div className="mb-5 flex items-start gap-3 p-3.5 bg-red-50 border border-red-100 rounded-xl">
              <AlertCircle className="h-5 w-5 text-red-500 mt-0.5 shrink-0" />
              <p className="text-sm text-red-700">{error}</p>
            </div>
          )}

          <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
            {/* Name */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1.5">
                Full Name <span className="text-red-400">*</span>
              </label>
              <div className="relative">
                <User className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400" />
                <input
                  {...register('name')}
                  type="text"
                  className={`w-full pl-10 pr-4 py-2.5 border rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-500 transition-all ${errors.name ? 'border-red-300' : 'border-gray-200'}`}
                  placeholder="Enter student name"
                />
              </div>
              {errors.name && (
                <p className="mt-1 text-xs text-red-500">{errors.name.message}</p>
              )}
            </div>

            {/* Email */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1.5">
                Email <span className="text-red-400">*</span>
              </label>
              <div className="relative">
                <Mail className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400" />
                <input
                  {...register('email')}
                  type="email"
                  className={`w-full pl-10 pr-4 py-2.5 border rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-500 transition-all ${errors.email ? 'border-red-300' : 'border-gray-200'}`}
                  placeholder="student@email.com"
                  disabled={!!student}
                />
              </div>
              {errors.email && (
                <p className="mt-1 text-xs text-red-500">{errors.email.message}</p>
              )}
            </div>

            {/* Password - only for new students */}
            {!student && (
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1.5">
                  Password <span className="text-red-400">*</span>
                </label>
                <div className="relative">
                  <Lock className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400" />
                  <input
                    {...register('password')}
                    type={showPassword ? 'text' : 'password'}
                    className="w-full pl-10 pr-10 py-2.5 border border-gray-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-500 transition-all"
                    placeholder="Min 6 characters"
                  />
                  <button
                    type="button"
                    onClick={() => setShowPassword(!showPassword)}
                    className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600"
                  >
                    {showPassword ? <EyeOff className="h-4 w-4" /> : <Eye className="h-4 w-4" />}
                  </button>
                </div>
                <p className="mt-1 text-xs text-gray-400">Student will use this to login in the app</p>
              </div>
            )}

            {/* Optional Fields Toggle */}
            <button
              type="button"
              onClick={() => setShowOptional(!showOptional)}
              className="text-sm text-teal-600 hover:text-teal-700 font-medium"
            >
              {showOptional ? '− Hide' : '+ Show'} optional fields
            </button>

            {showOptional && (
              <div className="space-y-4 pt-3 border-t border-gray-100">
                {/* Enrollment Number */}
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1.5">
                    Enrollment Number
                  </label>
                  <input
                    {...register('enrollmentNumber')}
                    type="text"
                    className="w-full px-4 py-2.5 border border-gray-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-500 transition-all"
                    placeholder="e.g., CSE2024001"
                  />
                </div>

                <div className="grid grid-cols-2 gap-3">
                  {/* Course */}
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1.5">
                      Course
                    </label>
                    <input
                      {...register('course')}
                      type="text"
                      className="w-full px-4 py-2.5 border border-gray-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-500 transition-all"
                      placeholder="e.g., B.Tech CSE"
                    />
                  </div>

                  {/* Batch */}
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1.5">
                      Batch
                    </label>
                    <input
                      {...register('batch')}
                      type="text"
                      className="w-full px-4 py-2.5 border border-gray-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-500 transition-all"
                      placeholder="e.g., 2024"
                    />
                  </div>
                </div>

                {/* Phone */}
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1.5">
                    Phone Number
                  </label>
                  <input
                    {...register('phone')}
                    type="tel"
                    className="w-full px-4 py-2.5 border border-gray-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-500 transition-all"
                    placeholder="+91 98765 43210"
                  />
                </div>
              </div>
            )}

            {/* Actions */}
            <div className="flex justify-end gap-3 pt-5 border-t border-gray-100 mt-6">
              <button
                type="button"
                onClick={onClose}
                className="px-4 py-2.5 text-sm font-medium text-gray-700 bg-gray-100 hover:bg-gray-200 rounded-xl transition-colors"
                disabled={isLoading}
              >
                Cancel
              </button>
              <button
                type="submit"
                disabled={isLoading}
                className="px-5 py-2.5 text-sm font-medium text-white bg-teal-600 hover:bg-teal-700 rounded-xl transition-colors disabled:opacity-50 flex items-center gap-2"
              >
                {isLoading ? (
                  <>
                    <div className="animate-spin rounded-full h-4 w-4 border-2 border-white border-t-transparent"></div>
                    {student ? 'Updating...' : 'Adding...'}
                  </>
                ) : (
                  <>
                    <Save className="h-4 w-4" />
                    {student ? 'Update' : 'Add Student'}
                  </>
                )}
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
  );
}