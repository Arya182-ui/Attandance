import { 
  Calendar, 
  Clock, 
  MapPin, 
  Download, 
  RefreshCw,
  Search,
  CheckCircle,
  XCircle,
  AlertCircle
} from 'lucide-react';
import { useState, useEffect } from 'react';
import { attendanceService } from '../services/attendance';
import { studentService } from '../services/students';
import type { Attendance, Student, AttendanceFilters } from '../types';
import { formatDate, formatTime, getStatusColor, formatStatus, downloadFile } from '../utils/helpers';

interface AttendanceRecordProps {
  attendance: Attendance;
  student?: Student;
}

function AttendanceRecord({ attendance, student }: AttendanceRecordProps) {
  const statusColor = getStatusColor(attendance.status);
  
  return (
    <div className="card p-4 hover:shadow-md transition-shadow">
      <div className="flex items-center justify-between">
        <div className="flex items-center space-x-4">
          {/* Status Icon */}
          <div className={`p-2 rounded-full ${statusColor}`}>
            {attendance.status === 'checked_in' && <CheckCircle className="h-5 w-5" />}
            {attendance.status === 'checked_out' && <CheckCircle className="h-5 w-5" />}
            {attendance.status === 'absent' && <XCircle className="h-5 w-5" />}
          </div>
          
          {/* Student Info */}
          <div>
            <h3 className="font-medium text-gray-900">
              {student?.name || `Student ${attendance.studentId.substring(0, 8)}...`}
            </h3>
            <p className="text-sm text-gray-600">
              {student?.enrollmentNumber || attendance.studentId}
            </p>
          </div>
        </div>

        {/* Status Badge */}
        <div className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${statusColor}`}>
          {formatStatus(attendance.status)}
        </div>
      </div>

      {/* Attendance Details */}
      <div className="mt-4 grid grid-cols-1 sm:grid-cols-3 gap-4 text-sm">
        <div className="flex items-center text-gray-600">
          <Calendar className="h-4 w-4 mr-2" />
          {formatDate(attendance.date)}
        </div>
        
        {attendance.checkInTime && (
          <div className="flex items-center text-gray-600">
            <Clock className="h-4 w-4 mr-2" />
            In: {formatTime(attendance.checkInTime)}
          </div>
        )}
        
        {attendance.checkOutTime && (
          <div className="flex items-center text-gray-600">
            <Clock className="h-4 w-4 mr-2" />
            Out: {formatTime(attendance.checkOutTime)}
          </div>
        )}
      </div>

      {/* Location Info */}
      {(attendance.checkInLocation || attendance.checkOutLocation) && (
        <div className="mt-3 pt-3 border-t border-gray-200">
          <div className="flex items-center text-xs text-gray-500">
            <MapPin className="h-4 w-4 mr-1" />
            Location tracked
          </div>
        </div>
      )}
    </div>
  );
}

export default function AttendancePage() {
  const [attendanceRecords, setAttendanceRecords] = useState<Attendance[]>([]);
  const [students, setStudents] = useState<Record<string, Student>>({});
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  
  // Filters
  const [selectedDate, setSelectedDate] = useState(new Date().toISOString().split('T')[0]);
  const [selectedStatus, setSelectedStatus] = useState<string>('');
  const [searchQuery, setSearchQuery] = useState('');
  
  // Stats
  const [stats, setStats] = useState({
    present: 0,
    absent: 0,
    total: 0,
    percentage: 0
  });

  const loadAttendanceData = async () => {
    try {
      setIsLoading(true);
      setError(null);
      
      // Load attendance records for selected date
      const startDate = new Date(selectedDate);
      const endDate = new Date(selectedDate);
      endDate.setDate(endDate.getDate() + 1);
      
      const filters: AttendanceFilters = {
        startDate,
        endDate
      };
      
      if (selectedStatus) {
        filters.status = selectedStatus as Attendance['status'];
      }

      const [attendanceData, studentsData] = await Promise.all([
        attendanceService.getAttendanceRecords(filters),
        studentService.getStudents()
      ]);

      // Create student lookup map
      const studentMap = studentsData.reduce((acc, student) => {
        acc[student.id] = student;
        return acc;
      }, {} as Record<string, Student>);

      setAttendanceRecords(attendanceData);
      setStudents(studentMap);
      
      // Calculate stats
      const presentStudents = new Set();
      attendanceData.forEach(record => {
        if (record.status === 'checked_in' || record.status === 'checked_out') {
          presentStudents.add(record.studentId);
        }
      });
      
      const totalStudents = studentsData.length;
      const presentCount = presentStudents.size;
      const absentCount = totalStudents - presentCount;
      
      setStats({
        present: presentCount,
        absent: absentCount,
        total: totalStudents,
        percentage: totalStudents > 0 ? (presentCount / totalStudents) * 100 : 0
      });
      
    } catch (err: any) {
      setError(err.message || 'Failed to load attendance data');
    } finally {
      setIsLoading(false);
    }
  };

  const exportAttendance = () => {
    try {
      const csv = attendanceService.exportToCSV(attendanceRecords, students);
      const filename = `attendance-${selectedDate}.csv`;
      downloadFile(csv, filename, 'text/csv');
    } catch (error) {
      alert('Failed to export attendance data');
    }
  };

  const filteredRecords = attendanceRecords.filter(record => {
    if (!searchQuery) return true;
    
    const student = students[record.studentId];
    const searchTerm = searchQuery.toLowerCase();
    
    return (
      student?.name.toLowerCase().includes(searchTerm) ||
      student?.enrollmentNumber?.toLowerCase().includes(searchTerm) ||
      record.studentId.toLowerCase().includes(searchTerm)
    );
  });

  useEffect(() => {
    loadAttendanceData();
  }, [selectedDate, selectedStatus]);

  if (isLoading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-teal-600"></div>
        <span className="ml-3 text-gray-600">Loading attendance data...</span>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Page Header */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Attendance Tracking</h1>
          <p className="mt-2 text-sm text-gray-600">
            Monitor and manage student attendance records
          </p>
        </div>
        <div className="mt-4 sm:mt-0 flex items-center space-x-3">
          <button
            onClick={loadAttendanceData}
            disabled={isLoading}
            className="btn-secondary flex items-center"
          >
            <RefreshCw className={`h-4 w-4 mr-2 ${isLoading ? 'animate-spin' : ''}`} />
            Refresh
          </button>
          <button
            onClick={exportAttendance}
            className="btn-primary flex items-center"
          >
            <Download className="h-4 w-4 mr-2" />
            Export CSV
          </button>
        </div>
      </div>

      {/* Stats Cards */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
        <div className="card p-6">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">Total Students</p>
              <p className="text-3xl font-bold text-gray-900">{stats.total}</p>
            </div>
            <div className="p-3 rounded-full bg-gray-100">
              <Calendar className="h-6 w-6 text-gray-600" />
            </div>
          </div>
        </div>

        <div className="card p-6">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">Present</p>
              <p className="text-3xl font-bold text-green-600">{stats.present}</p>
            </div>
            <div className="p-3 rounded-full bg-green-100">
              <CheckCircle className="h-6 w-6 text-green-600" />
            </div>
          </div>
        </div>

        <div className="card p-6">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">Absent</p>
              <p className="text-3xl font-bold text-red-600">{stats.absent}</p>
            </div>
            <div className="p-3 rounded-full bg-red-100">
              <XCircle className="h-6 w-6 text-red-600" />
            </div>
          </div>
        </div>

        <div className="card p-6">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">Attendance Rate</p>
              <p className="text-3xl font-bold text-teal-600">{stats.percentage.toFixed(1)}%</p>
            </div>
            <div className="p-3 rounded-full bg-teal-100">
              <AlertCircle className="h-6 w-6 text-teal-600" />
            </div>
          </div>
        </div>
      </div>

      {/* Filters */}
      <div className="card p-6">
        <div className="flex flex-col lg:flex-row lg:items-center lg:justify-between space-y-4 lg:space-y-0 lg:space-x-4">
          {/* Date Filter */}
          <div className="flex items-center space-x-4">
            <div className="flex items-center space-x-2">
              <Calendar className="h-5 w-5 text-gray-400" />
              <input
                type="date"
                value={selectedDate}
                onChange={(e) => setSelectedDate(e.target.value)}
                className="input-field"
              />
            </div>
            
            <select
              value={selectedStatus}
              onChange={(e) => setSelectedStatus(e.target.value)}
              className="input-field"
            >
              <option value="">All Status</option>
              <option value="checked_in">Checked In</option>
              <option value="checked_out">Checked Out</option>
              <option value="absent">Absent</option>
            </select>
          </div>

          {/* Search */}
          <div className="flex-1 max-w-lg">
            <div className="relative">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 h-5 w-5 text-gray-400" />
              <input
                type="text"
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                className="input-field pl-10"
                placeholder="Search by student name or enrollment number..."
              />
            </div>
          </div>
        </div>
      </div>

      {/* Error State */}
      {error && (
        <div className="card p-6 bg-red-50 border border-red-200">
          <p className="text-red-800">{error}</p>
          <button 
            onClick={loadAttendanceData}
            className="mt-2 btn-primary"
          >
            Retry
          </button>
        </div>
      )}

      {/* Attendance Records */}
      {!error && (
        <>
          <div className="flex items-center justify-between">
            <h2 className="text-lg font-semibold text-gray-900">
              Attendance for {formatDate(new Date(selectedDate))}
            </h2>
            <span className="text-sm text-gray-600">
              {filteredRecords.length} records
            </span>
          </div>

          <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
            {filteredRecords.length > 0 ? (
              filteredRecords.map(record => (
                <AttendanceRecord
                  key={record.id}
                  attendance={record}
                  student={students[record.studentId]}
                />
              ))
            ) : (
              <div className="col-span-full">
                <div className="text-center py-12">
                  <Calendar className="h-12 w-12 text-gray-400 mx-auto mb-4" />
                  <h3 className="text-lg font-medium text-gray-900 mb-2">No attendance records found</h3>
                  <p className="text-gray-600">
                    {searchQuery ? 'Try adjusting your search criteria' : 'No attendance recorded for the selected date'}
                  </p>
                </div>
              </div>
            )}
          </div>
        </>
      )}
    </div>
  );
}