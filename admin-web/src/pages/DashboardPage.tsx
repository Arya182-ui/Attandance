import React, { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { 
  Users, 
  UserCheck, 
  UserX, 
  TrendingUp,
  RefreshCw,
  Calendar,
  BarChart3,
  Plus,
  Settings,
  ClipboardCheck,
  ArrowRight,
  Activity
} from 'lucide-react';
import { dashboardService } from '../services/dashboard';
import type { DashboardStats } from '../types';
import { formatDate, formatTime, getRelativeTime } from '../utils/helpers';

interface StatCardProps {
  title: string;
  value: string | number;
  icon: React.ElementType;
  color: string;
  bgColor: string;
  change?: string;
}

function StatCard({ title, value, icon: Icon, color, bgColor, change }: StatCardProps) {
  return (
    <div className="bg-white rounded-2xl p-6 border border-gray-100 shadow-sm hover:shadow-lg transition-all duration-300 group">
      <div className="flex items-center justify-between">
        <div className="space-y-1">
          <p className="text-sm font-medium text-gray-500 uppercase tracking-wide">{title}</p>
          <p className="text-3xl font-bold text-gray-900">{value}</p>
          {change && (
            <p className="text-sm text-emerald-600 font-medium mt-1 flex items-center">
              <TrendingUp className="inline h-3.5 w-3.5 mr-1" />
              {change}
            </p>
          )}
        </div>
        <div className={`p-4 rounded-2xl ${bgColor} group-hover:scale-110 transition-transform duration-300`}>
          <Icon className={`h-6 w-6 ${color}`} />
        </div>
      </div>
    </div>
  );
}

export default function DashboardPage() {
  const navigate = useNavigate();
  const [stats, setStats] = useState<DashboardStats | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const loadDashboardStats = async () => {
    try {
      setIsLoading(true);
      setError(null);
      const data = await dashboardService.getDashboardStats();
      setStats(data);
    } catch (err: any) {
      setError(err.message || 'Failed to load dashboard statistics');
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    loadDashboardStats();
  }, []);

  if (isLoading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="relative">
          <div className="animate-spin rounded-full h-10 w-10 border-4 border-teal-200 border-t-teal-600"></div>
        </div>
        <span className="ml-4 text-gray-500 font-medium">Loading dashboard...</span>
      </div>
    );
  }

  if (error) {
    return (
      <div className="bg-white rounded-2xl p-12 text-center border border-gray-100 shadow-sm">
        <div className="inline-flex items-center justify-center w-16 h-16 rounded-full bg-red-50 mb-4">
          <BarChart3 className="h-8 w-8 text-red-500" />
        </div>
        <p className="text-lg font-semibold text-gray-900">Failed to load dashboard</p>
        <p className="text-sm text-gray-500 mt-2 mb-6">{error}</p>
        <button
          onClick={loadDashboardStats}
          className="btn-primary inline-flex items-center">
          <RefreshCw className="h-4 w-4 mr-2" />
          Retry
        </button>
      </div>
    );
  }

  if (!stats) return null;

  return (
    <div className="space-y-8">
      {/* Page Header */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Dashboard</h1>
          <p className="mt-1 text-sm text-gray-500">
            Welcome back! Here's today's overview.
          </p>
        </div>
        <div className="mt-4 sm:mt-0 flex items-center space-x-3">
          <button
            onClick={loadDashboardStats}
            disabled={isLoading}
            className="inline-flex items-center px-4 py-2.5 text-sm font-medium text-gray-700 bg-white border border-gray-200 rounded-xl hover:bg-gray-50 hover:border-gray-300 transition-all duration-200"
          >
            <RefreshCw className={`h-4 w-4 mr-2 ${isLoading ? 'animate-spin' : ''}`} />
            Refresh
          </button>
        </div>
      </div>

      {/* Stats Cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-5">
        <StatCard
          title="Total Students"
          value={stats.totalStudents}
          icon={Users}
          color="text-blue-600"
          bgColor="bg-blue-50"
        />
        <StatCard
          title="Present Today"
          value={stats.presentToday}
          icon={UserCheck}
          color="text-emerald-600"
          bgColor="bg-emerald-50"
        />
        <StatCard
          title="Absent Today"
          value={stats.absentToday}
          icon={UserX}
          color="text-red-500"
          bgColor="bg-red-50"
        />
        <StatCard
          title="Attendance Rate"
          value={`${stats.attendancePercentage.toFixed(1)}%`}
          icon={TrendingUp}
          color="text-teal-600"
          bgColor="bg-teal-50"
        />
      </div>

      {/* Main Content Grid */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Attendance Overview - Left Side */}
        <div className="lg:col-span-2 bg-white rounded-2xl p-6 border border-gray-100 shadow-sm">
          <div className="flex items-center justify-between mb-6">
            <div className="flex items-center space-x-2">
              <Activity className="h-5 w-5 text-teal-600" />
              <h3 className="text-lg font-semibold text-gray-900">Today's Attendance</h3>
            </div>
            <button 
              onClick={() => navigate('/attendance')}
              className="text-sm text-teal-600 hover:text-teal-700 font-medium flex items-center gap-1 hover:gap-2 transition-all"
            >
              View Details <ArrowRight className="h-4 w-4" />
            </button>
          </div>
          
          <div className="space-y-5">
            <div>
              <div className="flex items-center justify-between mb-2">
                <span className="text-sm font-medium text-gray-600">Present</span>
                <span className="text-sm font-bold text-emerald-600">{stats.presentToday} students</span>
              </div>
              <div className="w-full bg-gray-100 rounded-full h-3">
                <div 
                  className="bg-linear-to-r from-emerald-400 to-emerald-500 h-3 rounded-full transition-all duration-500" 
                  style={{ width: `${stats.attendancePercentage}%` }}
                ></div>
              </div>
            </div>
            
            <div>
              <div className="flex items-center justify-between mb-2">
                <span className="text-sm font-medium text-gray-600">Absent</span>
                <span className="text-sm font-bold text-red-500">{stats.absentToday} students</span>
              </div>
              <div className="w-full bg-gray-100 rounded-full h-3">
                <div 
                  className="bg-linear-to-r from-red-400 to-red-500 h-3 rounded-full transition-all duration-500" 
                  style={{ width: `${100 - stats.attendancePercentage}%` }}
                ></div>
              </div>
            </div>
          </div>

          <div className="mt-6 pt-4 border-t border-gray-100">
            <div className="flex items-center text-sm text-gray-500">
              <Calendar className="h-4 w-4 mr-2" />
              {formatDate(new Date())}
            </div>
          </div>
        </div>

        {/* Recent Activity - Right Side */}
        <div className="bg-white rounded-2xl p-6 border border-gray-100 shadow-sm">
          <div className="flex items-center justify-between mb-6">
            <h3 className="text-lg font-semibold text-gray-900">Recent Activity</h3>
          </div>
          
          <div className="space-y-3">
            {stats.recentAttendance.length > 0 ? (
              stats.recentAttendance.slice(0, 5).map((record) => (
                <div key={record.id} className="flex items-center space-x-3 p-3 rounded-xl hover:bg-gray-50 transition-colors">
                  <div className={`h-2.5 w-2.5 rounded-full shrink-0 ${
                    record.status === 'checked_in' ? 'bg-emerald-400' :
                    record.status === 'checked_out' ? 'bg-blue-400' : 'bg-red-400'
                  }`}></div>
                  <div className="flex-1 min-w-0">
                    <p className="text-sm font-medium text-gray-800 truncate">
                      {record.studentId.substring(0, 8)}...
                    </p>
                    <p className="text-xs text-gray-400">
                      {record.checkInTime ? formatTime(record.checkInTime) : 'No time'} • {getRelativeTime(record.createdAt)}
                    </p>
                  </div>
                  <span className={`text-xs font-medium px-2 py-1 rounded-full ${
                    record.status === 'checked_in' ? 'bg-emerald-50 text-emerald-600' :
                    record.status === 'checked_out' ? 'bg-blue-50 text-blue-600' : 'bg-red-50 text-red-600'
                  }`}>
                    {record.status === 'checked_in' ? 'In' : record.status === 'checked_out' ? 'Out' : 'Absent'}
                  </span>
                </div>
              ))
            ) : (
              <div className="text-center py-8">
                <div className="inline-flex items-center justify-center w-12 h-12 rounded-full bg-gray-50 mb-3">
                  <UserCheck className="h-6 w-6 text-gray-300" />
                </div>
                <p className="text-sm text-gray-400">No recent activity</p>
              </div>
            )}
          </div>
        </div>
      </div>

      {/* Quick Actions */}
      <div className="bg-white rounded-2xl p-6 border border-gray-100 shadow-sm">
        <h3 className="text-lg font-semibold text-gray-900 mb-5">Quick Actions</h3>
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
          <button 
            onClick={() => navigate('/students')}
            className="flex items-center p-4 rounded-xl border border-gray-100 hover:border-teal-200 hover:bg-teal-50/50 transition-all duration-200 group"
          >
            <div className="p-2.5 rounded-lg bg-teal-50 group-hover:bg-teal-100 transition-colors mr-3">
              <Users className="h-5 w-5 text-teal-600" />
            </div>
            <div className="text-left">
              <span className="text-sm font-semibold text-gray-800">Students</span>
              <p className="text-xs text-gray-400">Manage all students</p>
            </div>
            <ArrowRight className="h-4 w-4 text-gray-300 ml-auto group-hover:text-teal-400 group-hover:translate-x-1 transition-all" />
          </button>

          <button 
            onClick={() => navigate('/attendance')}
            className="flex items-center p-4 rounded-xl border border-gray-100 hover:border-blue-200 hover:bg-blue-50/50 transition-all duration-200 group"
          >
            <div className="p-2.5 rounded-lg bg-blue-50 group-hover:bg-blue-100 transition-colors mr-3">
              <ClipboardCheck className="h-5 w-5 text-blue-600" />
            </div>
            <div className="text-left">
              <span className="text-sm font-semibold text-gray-800">Attendance</span>
              <p className="text-xs text-gray-400">View records</p>
            </div>
            <ArrowRight className="h-4 w-4 text-gray-300 ml-auto group-hover:text-blue-400 group-hover:translate-x-1 transition-all" />
          </button>

          <button 
            onClick={() => navigate('/students')}
            className="flex items-center p-4 rounded-xl border border-gray-100 hover:border-emerald-200 hover:bg-emerald-50/50 transition-all duration-200 group"
          >
            <div className="p-2.5 rounded-lg bg-emerald-50 group-hover:bg-emerald-100 transition-colors mr-3">
              <Plus className="h-5 w-5 text-emerald-600" />
            </div>
            <div className="text-left">
              <span className="text-sm font-semibold text-gray-800">Add Student</span>
              <p className="text-xs text-gray-400">Register new</p>
            </div>
            <ArrowRight className="h-4 w-4 text-gray-300 ml-auto group-hover:text-emerald-400 group-hover:translate-x-1 transition-all" />
          </button>

          <button 
            onClick={() => navigate('/settings')}
            className="flex items-center p-4 rounded-xl border border-gray-100 hover:border-gray-200 hover:bg-gray-50/50 transition-all duration-200 group"
          >
            <div className="p-2.5 rounded-lg bg-gray-50 group-hover:bg-gray-100 transition-colors mr-3">
              <Settings className="h-5 w-5 text-gray-600" />
            </div>
            <div className="text-left">
              <span className="text-sm font-semibold text-gray-800">Settings</span>
              <p className="text-xs text-gray-400">Configure system</p>
            </div>
            <ArrowRight className="h-4 w-4 text-gray-300 ml-auto group-hover:text-gray-400 group-hover:translate-x-1 transition-all" />
          </button>
        </div>
      </div>
    </div>
  );
}