import { studentService } from './students';
import { attendanceService } from './attendance';
import type { DashboardStats } from '../types';

class DashboardService {
  
  // Get dashboard statistics
  async getDashboardStats(): Promise<DashboardStats> {
    try {
      // Get all students count
      const students = await studentService.getStudents();
      const totalStudents = students.length;

      // Get today's attendance
      const todayAttendance = await attendanceService.getTodayAttendance();
      
      // Count present and absent students
      const presentStudentIds = new Set(
        todayAttendance
          .filter(record => record.status === 'checked_in' || record.status === 'checked_out')
          .map(record => record.studentId)
      );
      
      const presentToday = presentStudentIds.size;
      const absentToday = totalStudents - presentToday;
      
      // Calculate attendance percentage
      const attendancePercentage = totalStudents > 0 ? (presentToday / totalStudents) * 100 : 0;

      // Get recent attendance records (last 10)
      const allAttendance = await attendanceService.getAttendanceRecords();
      const recentAttendance = allAttendance.slice(0, 10);

      return {
        totalStudents,
        presentToday,
        absentToday,
        attendancePercentage: Math.round(attendancePercentage * 100) / 100, // Round to 2 decimal places
        recentAttendance
      };
    } catch (error) {
      console.error('Error fetching dashboard stats:', error);
      throw new Error('Failed to fetch dashboard statistics');
    }
  }

  // Get weekly attendance summary
  async getWeeklyAttendanceStats(): Promise<{
    labels: string[];
    presentData: number[];
    absentData: number[];
  }> {
    try {
      const today = new Date();
      const weekStart = new Date(today);
      weekStart.setDate(today.getDate() - 6); // Last 7 days
      weekStart.setHours(0, 0, 0, 0);

      const students = await studentService.getStudents();
      const totalStudents = students.length;
      
      const labels: string[] = [];
      const presentData: number[] = [];
      const absentData: number[] = [];

      for (let i = 0; i < 7; i++) {
        const date = new Date(weekStart);
        date.setDate(weekStart.getDate() + i);
        
        const nextDay = new Date(date);
        nextDay.setDate(date.getDate() + 1);

        // Get attendance for this day
        const dayAttendance = await attendanceService.getAttendanceRecords({
          startDate: date,
          endDate: nextDay
        });

        const presentCount = new Set(
          dayAttendance
            .filter(record => record.status === 'checked_in' || record.status === 'checked_out')
            .map(record => record.studentId)
        ).size;

        const absentCount = totalStudents - presentCount;

        labels.push(date.toLocaleDateString('en-US', { weekday: 'short' }));
        presentData.push(presentCount);
        absentData.push(absentCount);
      }

      return {
        labels,
        presentData,
        absentData
      };
    } catch (error) {
      console.error('Error fetching weekly stats:', error);
      throw new Error('Failed to fetch weekly statistics');
    }
  }

  // Get monthly attendance summary
  async getMonthlyAttendanceStats(year: number, month: number): Promise<{
    totalWorkingDays: number;
    averageAttendance: number;
    bestAttendanceDay: { date: string; percentage: number };
    worstAttendanceDay: { date: string; percentage: number };
  }> {
    try {
      const monthStart = new Date(year, month - 1, 1);
      const monthEnd = new Date(year, month, 0);
      
      const students = await studentService.getStudents();
      const totalStudents = students.length;
      
      if (totalStudents === 0) {
        return {
          totalWorkingDays: 0,
          averageAttendance: 0,
          bestAttendanceDay: { date: '', percentage: 0 },
          worstAttendanceDay: { date: '', percentage: 0 }
        };
      }

      const monthAttendance = await attendanceService.getAttendanceRecords({
        startDate: monthStart,
        endDate: monthEnd
      });

      // Group by date
      const dailyStats: Record<string, number> = {};
      const processedDates = new Set<string>();

      monthAttendance.forEach(record => {
        const dateKey = record.date.toISOString().split('T')[0];
        if (!processedDates.has(dateKey + record.studentId)) {
          if (!dailyStats[dateKey]) dailyStats[dateKey] = 0;
          if (record.status === 'checked_in' || record.status === 'checked_out') {
            dailyStats[dateKey]++;
          }
          processedDates.add(dateKey + record.studentId);
        }
      });

      const workingDays = Object.keys(dailyStats);
      const totalWorkingDays = workingDays.length;
      
      if (totalWorkingDays === 0) {
        return {
          totalWorkingDays: 0,
          averageAttendance: 0,
          bestAttendanceDay: { date: '', percentage: 0 },
          worstAttendanceDay: { date: '', percentage: 0 }
        };
      }

      // Calculate daily percentages
      const dailyPercentages = workingDays.map(date => ({
        date,
        percentage: (dailyStats[date] / totalStudents) * 100
      }));

      // Find best and worst days
      const bestDay = dailyPercentages.reduce((best, day) => 
        day.percentage > best.percentage ? day : best
      );
      
      const worstDay = dailyPercentages.reduce((worst, day) => 
        day.percentage < worst.percentage ? day : worst
      );

      // Calculate average
      const averageAttendance = dailyPercentages.reduce((sum, day) => 
        sum + day.percentage, 0
      ) / totalWorkingDays;

      return {
        totalWorkingDays,
        averageAttendance: Math.round(averageAttendance * 100) / 100,
        bestAttendanceDay: {
          date: new Date(bestDay.date).toLocaleDateString(),
          percentage: Math.round(bestDay.percentage * 100) / 100
        },
        worstAttendanceDay: {
          date: new Date(worstDay.date).toLocaleDateString(),
          percentage: Math.round(worstDay.percentage * 100) / 100
        }
      };
    } catch (error) {
      console.error('Error fetching monthly stats:', error);
      throw new Error('Failed to fetch monthly statistics');
    }
  }
}

export const dashboardService = new DashboardService();