export interface User {
  id: string;
  name: string;
  email: string;
  role: 'admin' | 'student';
}

export interface LocationPoint {
  latitude: number;
  longitude: number;
}

export interface Attendance {
  id: string;
  studentId: string;
  date: Date;
  checkInTime?: Date;
  checkOutTime?: Date;
  checkInLocation?: LocationPoint;
  checkOutLocation?: LocationPoint;
  status: 'checked_in' | 'checked_out' | 'absent';
  createdAt: Date;
}

export interface Institute {
  id: string;
  name: string;
  address: string;
  location?: LocationPoint;
  allowedRadius: number; // in meters
  adminEmails: string[];
  createdAt: Date;
  updatedAt: Date;
}

export interface DashboardStats {
  totalStudents: number;
  presentToday: number;
  absentToday: number;
  attendancePercentage: number;
  recentAttendance: Attendance[];
}

export interface Student extends User {
  role: 'student';
  enrollmentNumber: string;
  course: string;
  batch: string;
  profileImageUrl?: string;
  phone?: string;
  address?: string;
  dateOfBirth?: string;
  instituteId?: string;
  createdAt?: Date;
  updatedAt?: Date;
}

// Auth related types
export interface AuthUser {
  id: string;
  email: string;
  name: string;
  role: string;
}

export interface LoginCredentials {
  email: string;
  password: string;
}

// API Response types
export interface ApiResponse<T> {
  success: boolean;
  data?: T;
  error?: string;
  message?: string;
}

// Query and Filter types
export interface StudentFilters {
  search?: string;
  course?: string;
  batch?: string;
}

export interface AttendanceFilters {
  studentId?: string;
  startDate?: Date;
  endDate?: Date;
  status?: Attendance['status'];
}