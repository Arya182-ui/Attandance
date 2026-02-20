import { 
  collection, 
  getDocs, 
  doc, 
  getDoc, 
  updateDoc,
  setDoc,
  query,
  where,
  orderBy,
  limit,
  Timestamp
} from 'firebase/firestore';
import { db } from './firebase';
import type { Attendance, AttendanceFilters } from '../types';

class AttendanceService {
  private readonly collectionName = 'attendance';

  // Get attendance records with filters
  async getAttendanceRecords(filters?: AttendanceFilters): Promise<Attendance[]> {
    try {
      let q = query(
        collection(db, this.collectionName),
        orderBy('date', 'desc'),
        limit(100) // Limit for performance
      );

      // Apply Firestore filters
      if (filters?.studentId) {
        q = query(
          collection(db, this.collectionName),
          where('studentId', '==', filters.studentId),
          orderBy('date', 'desc')
        );
      }

      const snapshot = await getDocs(q);
      
      let records = snapshot.docs.map(doc => {
        const data = doc.data();
        return {
          id: doc.id,
          ...data,
          date: data.date?.toDate() || new Date(),
          checkInTime: data.checkInTime?.toDate() || null,
          checkOutTime: data.checkOutTime?.toDate() || null,
          createdAt: data.createdAt?.toDate() || new Date()
        } as Attendance;
      });

      // Apply client-side date filters
      if (filters?.startDate || filters?.endDate) {
        records = records.filter(record => {
          const recordDate = record.date;
          
          // Use local date comparison (avoid timezone issues)
          const recordYear = recordDate.getFullYear();
          const recordMonth = recordDate.getMonth();
          const recordDay = recordDate.getDate();
          
          const startYear = filters?.startDate?.getFullYear();
          const startMonth = filters?.startDate?.getMonth();
          const startDay = filters?.startDate?.getDate();
          
          const endYear = filters?.endDate?.getFullYear();
          const endMonth = filters?.endDate?.getMonth();
          const endDay = filters?.endDate?.getDate();
          
          // Create date objects for comparison (same timezone)
          const recordDateOnly = new Date(recordYear, recordMonth, recordDay);
          const startDateOnly = filters?.startDate ? new Date(startYear!, startMonth!, startDay!) : null;
          const endDateOnly = filters?.endDate ? new Date(endYear!, endMonth!, endDay!) : null;
          
          if (startDateOnly && recordDateOnly < startDateOnly) return false;
          if (endDateOnly && recordDateOnly >= endDateOnly) return false;
          return true;
        });
      }

      if (filters?.status) {
        records = records.filter(record => record.status === filters.status);
      }

      return records;
    } catch (error) {
      console.error('Error fetching attendance records:', error);
      throw new Error('Failed to fetch attendance records');
    }
  }

  // Get attendance for today
  async getTodayAttendance(): Promise<Attendance[]> {
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    
    const tomorrow = new Date(today);
    tomorrow.setDate(tomorrow.getDate() + 1);

    return this.getAttendanceRecords({
      startDate: today,
      endDate: tomorrow
    });
  }

  // Get attendance by student ID for a date range
  async getStudentAttendance(
    studentId: string, 
    startDate?: Date, 
    endDate?: Date
  ): Promise<Attendance[]> {
    return this.getAttendanceRecords({
      studentId,
      startDate,
      endDate
    });
  }

  // Helper to format date as YYYY-MM-DD
  private formatDate(date: Date): string {
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    return `${year}-${month}-${day}`;
  }

  // Helper to normalize date (remove time component)
  private normalizeDate(date: Date): Date {
    return new Date(date.getFullYear(), date.getMonth(), date.getDate());
  }

  // Mark attendance (check-in or check-out)
  // IMPORTANT: Uses same document ID format as student app (studentId_dateStr)
  async markAttendance(attendanceData: {
    studentId: string;
    checkInTime?: Date;
    checkOutTime?: Date;
    checkInLocation?: { latitude: number; longitude: number };
    checkOutLocation?: { latitude: number; longitude: number };
    status: Attendance['status'];
  }): Promise<string> {
    try {
      const today = this.normalizeDate(new Date());
      const dateStr = this.formatDate(today);
      // Use same document ID format as student app
      const docId = `${attendanceData.studentId}_${dateStr}`;
      const docRef = doc(db, this.collectionName, docId);

      // Check if attendance already exists
      const docSnap = await getDoc(docRef);

      if (docSnap.exists()) {
        // Update existing attendance
        const updateData: any = {
          status: attendanceData.status,
          updatedAt: Timestamp.fromDate(new Date())
        };
        
        if (attendanceData.checkInTime) {
          updateData.checkInTime = Timestamp.fromDate(attendanceData.checkInTime);
        }
        if (attendanceData.checkOutTime) {
          updateData.checkOutTime = Timestamp.fromDate(attendanceData.checkOutTime);
        }
        if (attendanceData.checkInLocation) {
          updateData.checkInLocation = attendanceData.checkInLocation;
        }
        if (attendanceData.checkOutLocation) {
          updateData.checkOutLocation = attendanceData.checkOutLocation;
        }
        
        await updateDoc(docRef, updateData);
      } else {
        // Create new attendance record with specific document ID (same as student app)
        await setDoc(docRef, {
          studentId: attendanceData.studentId,
          date: Timestamp.fromDate(today),
          checkInTime: attendanceData.checkInTime ? Timestamp.fromDate(attendanceData.checkInTime) : null,
          checkOutTime: attendanceData.checkOutTime ? Timestamp.fromDate(attendanceData.checkOutTime) : null,
          checkInLocation: attendanceData.checkInLocation || null,
          checkOutLocation: attendanceData.checkOutLocation || null,
          status: attendanceData.status,
          createdAt: Timestamp.fromDate(new Date())
        });
      }
      return docId;
    } catch (error) {
      console.error('Error marking attendance:', error);
      throw new Error('Failed to mark attendance');
    }
  }

  // Get attendance statistics for date range
  async getAttendanceStats(startDate: Date, endDate: Date): Promise<{
    totalDays: number;
    totalPresent: number;
    totalAbsent: number;
    attendanceRate: number;
  }> {
    try {
      const records = await this.getAttendanceRecords({ startDate, endDate });
      
      const totalDays = Math.ceil((endDate.getTime() - startDate.getTime()) / (1000 * 60 * 60 * 24)) + 1;
      const presentDays = records.filter(r => r.status === 'checked_in' || r.status === 'checked_out').length;
      const absentDays = totalDays - presentDays;
      
      return {
        totalDays,
        totalPresent: presentDays,
        totalAbsent: absentDays,
        attendanceRate: totalDays > 0 ? (presentDays / totalDays) * 100 : 0
      };
    } catch (error) {
      console.error('Error calculating attendance stats:', error);
      throw new Error('Failed to calculate attendance statistics');
    }
  }

  // Export attendance to CSV format
  exportToCSV(records: Attendance[], studentData?: Record<string, { name: string; enrollmentNumber: string }>): string {
    const headers = ['Date', 'Student Name', 'Enrollment No.', 'Check In', 'Check Out', 'Status'];
    
    const rows = records.map(record => [
      record.date.toISOString().split('T')[0],
      studentData?.[record.studentId]?.name || record.studentId,
      studentData?.[record.studentId]?.enrollmentNumber || '',
      record.checkInTime ? record.checkInTime.toLocaleTimeString() : '',
      record.checkOutTime ? record.checkOutTime.toLocaleTimeString() : '',
      record.status
    ]);

    const csv = [headers, ...rows]
      .map(row => row.map(cell => `"${cell}"`).join(','))
      .join('\n');

    return csv;
  }
}

export const attendanceService = new AttendanceService();