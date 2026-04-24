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
    <div className="bg-white rounded-2xl p-4 sm:p-6 border border-gray-100 shadow-sm hover:shadow-md transition-all duration-300 group">
      <div className="flex items-center justify-between">
        <div className="space-y-1">
          <p className="text-xs sm:text-sm font-semibold text-gray-500 uppercase tracking-wider">{title}</p>
          <p className="text-2xl sm:text-3xl font-bold text-gray-900 tracking-tight">{value}</p>
          {change && (
            <p className="text-xs sm:text-sm text-emerald-600 font-bold mt-1.5 flex items-center">
              <TrendingUp className="inline h-3.5 w-3.5 mr-1" />
              {change}
            </p>
          )}
        </div>
        <div className={`p-3 sm:p-4 rounded-xl sm:rounded-2xl ${bgColor} group-hover:scale-110 transition-transform duration-300 shadow-sm`}>
          <Icon className={`h-5 w-5 sm:h-6 sm:w-6 ${color}`} />
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
      <div className="flex flex-col items-center justify-center min-h-100">
        <div className="relative">
          <div className="animate-spin rounded-full h-12 w-12 border-[3px] border-teal-100 border-t-teal-600"></div>
        </div>
        <span className="mt-4 text-gray-500 font-semibold animate-pulse">Loading dashboard...</span>
      </div>
    );
  }

  if (error) {
    return (
      <div className="bg-white rounded-3xl p-8 sm:p-12 text-center border border-gray-100 shadow-sm">
        <div className="inline-flex items-center justify-center w-16 h-16 rounded-2xl bg-red-50 mb-6">
          <BarChart3 className="h-8 w-8 text-red-500" />
        </div>
        <p className="text-xl font-bold text-gray-900">Failed to load dashboard</p>
        <p className="text-sm text-gray-500 mt-2 mb-8 max-w-xs mx-auto">{error}</p>
        <button
          onClick={loadDashboardStats}
          className="w-full sm:w-auto px-8 py-3 bg-teal-600 text-white font-bold rounded-xl hover:bg-teal-700 active:scale-95 transition-all flex items-center justify-center">
          <RefreshCw className="h-4 w-4 mr-2" />
          Retry Now
        </button>
      </div>
    );
  }

  if (!stats) return null;

  return (
    <div className="space-y-6 sm:space-y-8 pb-10">
      {/* Page Header */}
      <div className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
        <div>
          <h1 className="text-2xl sm:text-3xl font-extrabold text-gray-900 tracking-tight">Dashboard</h1>
          <p className="mt-1 text-sm font-medium text-gray-500 flex items-center">
            <Activity className="h-4 w-4 mr-1.5 text-teal-500" />
            Supercharge your attendance management
          </p>
        </div>
        <div className="flex items-center space-x-3">
          <button
            onClick={loadDashboardStats}
            disabled={isLoading}
            className="flex-1 sm:flex-none inline-flex items-center justify-center px-4 py-2.5 text-sm font-bold text-gray-700 bg-white border border-gray-200 rounded-xl hover:bg-gray-50 active:bg-gray-100 transition-all shadow-sm"
          >
            <RefreshCw className={`h-4 w-4 mr-2 ${isLoading ? 'animate-spin' : ''}`} />
            Refresh
          </button>
        </div>
      </div>

      {/* Stats Cards */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4 sm:gap-6">
        <StatCard
          title="Students"
          value={stats.totalStudents}
          icon={Users}
          color="text-blue-600"
          bgColor="bg-blue-50"
        />
        <StatCard
          title="Present"
          value={stats.presentToday}
          icon={UserCheck}
          color="text-emerald-600"
          bgColor="bg-emerald-50"
        />
        <StatCard
          title="Absent"
          value={stats.absentToday}
          icon={UserX}
          color="text-red-500"
          bgColor="bg-red-50"
        />
        <StatCard
          title="Ratio"
          value={`${stats.attendancePercentage.toFixed(0)}%`}
          icon={TrendingUp}
          color="text-teal-600"
          bgColor="bg-teal-50"
        />
      </div>

      {/* Main Content Grid */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6 sm:gap-8">
        {/* Attendance Overview - Left Side */}
        <div className="lg:col-span-2 bg-white rounded-3xl p-5 sm:p-8 border border-gray-100 shadow-sm relative overflow-hidden group">
          <div className="flex items-center justify-between mb-8 relative z-10">
            <div className="flex items-center space-x-3">
              <div className="p-2.5 bg-teal-50 rounded-xl">
                <Activity className="h-6 w-6 text-teal-600" />
              </div>
              <h3 className="text-xl font-bold text-gray-900 tracking-tight">Today's Attendance</h3>
            </div>
            <button 
              onClick={() => navigate('/attendance')}
              className="px-4 py-2 text-sm text-teal-600 bg-teal-50 hover:bg-teal-100 font-bold rounded-xl transition-all"
            >
              View Detailed Report
            </button>
          </div>
          
          <div className="space-y-8 relative z-10">
            <div>
              <div className="flex items-center justify-between mb-3">
                <div className="flex items-center">
                  <div className="h-2 w-2 rounded-full bg-emerald-500 mr-2" />
                  <span className="text-sm font-bold text-gray-700">Present Today</span>
                </div>
                <span className="text-lg font-black text-emerald-600">{stats.presentToday} students</span>
              </div>
              <div className="w-full bg-gray-50 rounded-2xl h-4 border border-gray-100 p-0.5">
                <div 
                  className="bg-linear-to-r from-emerald-400 via-emerald-500 to-teal-500 h-full rounded-2xl transition-all duration-700 ease-out shadow-sm" 
                  style={{ width: `${stats.attendancePercentage}%` }}
                ></div>
              </div>
            </div>
            
            <div>
              <div className="flex items-center justify-between mb-3">
                <div className="flex items-center">
                  <div className="h-2 w-2 rounded-full bg-red-400 mr-2" />
                  <span className="text-sm font-bold text-gray-700">Absent Today</span>
                </div>
                <span className="text-lg font-black text-red-500">{stats.absentToday} students</span>
              </div>
              <div className="w-full bg-gray-50 rounded-2xl h-4 border border-gray-100 p-0.5">
                <div 
                  className="bg-linear-to-r from-red-400 to-red-500 h-full rounded-2xl transition-all duration-700 ease-out shadow-sm" 
                  style={{ width: `${100 - stats.attendancePercentage}%` }}
                ></div>
              </div>
            </div>
          </div>

          <div className="mt-10 pt-6 border-t border-gray-100 flex items-center justify-between text-gray-400">
            <div className="flex items-center text-sm font-medium">
              <Calendar className="h-4 w-4 mr-2" />
              {formatDate(new Date())}
            </div>
            <span className="text-[10px] uppercase font-bold tracking-widest">Real-time update</span>
          </div>
        </div>

        {/* Recent Activity - Right Side */}
        <div className="bg-white rounded-3xl p-5 sm:p-8 border border-gray-100 shadow-sm flex flex-col h-full">
          <div className="flex items-center justify-between mb-8">
            <h3 className="text-xl font-bold text-gray-900 tracking-tight">Activity Log</h3>
            <span className="p-1 px-2.5 bg-gray-50 text-[10px] font-black text-gray-400 rounded-lg uppercase tracking-wider">Latest</span>
          </div>
          
          <div className="space-y-4 flex-1 overflow-y-auto max-h-120 pr-2 custom-scrollbar">
            {stats.recentAttendance.length > 0 ? (
              stats.recentAttendance.slice(0, 8).map((record) => (
                <div key={record.id} className="flex items-center space-x-4 p-4 rounded-2xl bg-gray-50/30 hover:bg-gray-50 transition-all border border-transparent hover:border-gray-100 group">
                  <div className={`h-3 w-3 rounded-full ring-4 shadow-sm shrink-0 ${
                    record.status === 'checked_in' ? 'bg-emerald-500 ring-emerald-50' :
                    record.status === 'checked_out' ? 'bg-blue-500 ring-blue-50' : 'bg-red-500 ring-red-50'
                  }`}></div>
                  <div className="flex-1 min-w-0">
                    <p className="text-sm font-bold text-gray-800 truncate group-hover:text-teal-700 transition-colors">
                      {record.studentId.substring(0, 8).toUpperCase()}
                    </p>
                    <p className="text-xs font-medium text-gray-400 flex items-center mt-0.5">
                      <span className="mr-2">{getRelativeTime(record.createdAt)}</span>
                      <span className="w-1 h-1 bg-gray-300 rounded-full mr-2" />
                      <span>{record.checkInTime ? formatTime(record.checkInTime) : 'N/A'}</span>
                    </p>
                  </div>
                  <span className={`text-[10px] font-black px-2.5 py-1 rounded-lg uppercase tracking-tighter ${
                    record.status === 'checked_in' ? 'bg-emerald-100 text-emerald-700' :
                    record.status === 'checked_out' ? 'bg-blue-100 text-blue-700' : 'bg-red-100 text-red-700'
                  }`}>
                    {record.status === 'checked_in' ? 'IN' : record.status === 'checked_out' ? 'OUT' : 'ABS'}
                  </span>
                </div>
              ))
            ) : (
              <div className="text-center py-16">
                <div className="inline-flex items-center justify-center w-16 h-16 rounded-3xl bg-gray-50 mb-4 animate-bounce">
                  <UserCheck className="h-8 w-8 text-gray-300" />
                </div>
                <p className="text-sm font-bold text-gray-400">No activity today yet</p>
              </div>
            )}
          </div>
        </div>
      </div>

      {/* Quick Actions */}
      <div className="bg-white/50 backdrop-blur-sm rounded-3xl p-6 sm:p-8 border border-gray-100 shadow-sm overflow-hidden relative">
        <div className="absolute top-0 right-0 p-8 opacity-5">
            <Settings className="h-32 w-32" />
        </div>
        <h3 className="text-xl font-black text-gray-900 mb-8 tracking-tight relative z-10">Smart Actions</h3>
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 sm:gap-6 relative z-10">
          <button 
            onClick={() => navigate('/students')}
            className="flex items-center p-5 rounded-2xl bg-white border border-gray-100 hover:border-teal-200 hover:shadow-xl hover:shadow-teal-100/50 transition-all duration-300 group"
          >
            <div className="p-3.5 rounded-xl bg-teal-50 group-hover:bg-teal-600 transition-all duration-300 shadow-inner mr-4">
              <Users className="h-6 w-6 text-teal-600 group-hover:text-white" />
            </div>
            <div className="text-left">
              <span className="text-sm font-black text-gray-800 group-hover:text-teal-700 transition-colors">Students List</span>
              <p className="text-xs font-medium text-gray-400 mt-1">Full database view</p>
            </div>
          </button>

          <button 
            onClick={() => navigate('/attendance')}
            className="flex items-center p-5 rounded-2xl bg-white border border-gray-100 hover:border-blue-200 hover:shadow-xl hover:shadow-blue-100/50 transition-all duration-300 group"
          >
            <div className="p-3.5 rounded-xl bg-blue-50 group-hover:bg-blue-600 transition-all duration-300 shadow-inner mr-4">
              <ClipboardCheck className="h-6 w-6 text-blue-600 group-hover:text-white" />
            </div>
            <div className="text-left">
              <span className="text-sm font-black text-gray-800 group-hover:text-blue-700 transition-colors">Logs</span>
              <p className="text-xs font-medium text-gray-400 mt-1">Verify records</p>
            </div>
          </button>

          <button 
            onClick={() => navigate('/students')}
            className="flex items-center p-5 rounded-2xl bg-white border border-gray-100 hover:border-emerald-200 hover:shadow-xl hover:shadow-emerald-100/50 transition-all duration-300 group"
          >
            <div className="p-3.5 rounded-xl bg-emerald-50 group-hover:bg-emerald-600 transition-all duration-300 shadow-inner mr-4">
              <Plus className="h-6 w-6 text-emerald-600 group-hover:text-white" />
            </div>
            <div className="text-left">
              <span className="text-sm font-black text-gray-800 group-hover:text-emerald-700 transition-colors">New Entry</span>
              <p className="text-xs font-medium text-gray-400 mt-1">Registration form</p>
            </div>
          </button>

          <button 
            onClick={() => navigate('/settings')}
            className="flex items-center p-5 rounded-2xl bg-white border border-gray-100 hover:border-gray-300 hover:shadow-xl transition-all duration-300 group"
          >
            <div className="p-3.5 rounded-xl bg-gray-50 group-hover:bg-gray-800 transition-all duration-300 shadow-inner mr-4">
              <Settings className="h-6 w-6 text-gray-600 group-hover:text-white" />
            </div>
            <div className="text-left">
              <span className="text-sm font-black text-gray-800 group-hover:text-gray-950 transition-colors">Settings</span>
              <p className="text-xs font-medium text-gray-400 mt-1">Config system</p>
            </div>
          </button>
        </div>
      </div>
    </div>
  );
}