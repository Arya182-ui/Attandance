import { useState } from 'react';
import { Trash2, Edit, Phone, Mail, Users2, BookOpen, Calendar } from 'lucide-react';
import type { Student } from '../types';
import { cn } from '../utils/helpers';

interface StudentTableProps {
  students: Student[];
  onEdit: (student: Student) => void;
  onDelete: (studentId: string) => void;
  isLoading?: boolean;
}

export default function StudentTable({ students, onEdit, onDelete, isLoading = false }: StudentTableProps) {
  const [deleteConfirmId, setDeleteConfirmId] = useState<string | null>(null);

  const handleDelete = (student: Student) => {
    if (deleteConfirmId === student.id) {
      onDelete(student.id);
      setDeleteConfirmId(null);
    } else {
      setDeleteConfirmId(student.id);
      setTimeout(() => {
        setDeleteConfirmId(null);
      }, 3000);
    }
  };

  const formatPhone = (phone?: string) => {
    if (!phone) return 'Not provided';
    const cleaned = phone.replace(/\D/g, '');
    if (cleaned.length === 10) {
      return `(${cleaned.slice(0, 3)}) ${cleaned.slice(3, 6)}-${cleaned.slice(6)}`;
    }
    return phone;
  };

  if (isLoading) {
    return (
      <div className="bg-white rounded-3xl border border-gray-100 p-8">
        <div className="animate-pulse space-y-6">
          <div className="h-10 bg-gray-100 rounded-xl w-1/4"></div>
          {[...Array(5)].map((_, i) => (
            <div key={i} className="flex gap-4">
              <div className="h-14 w-14 bg-gray-100 rounded-2xl"></div>
              <div className="flex-1 space-y-2">
                <div className="h-5 bg-gray-100 rounded-lg w-1/3"></div>
                <div className="h-4 bg-gray-50 rounded-lg w-1/4"></div>
              </div>
            </div>
          ))}
        </div>
      </div>
    );
  }

  if (students.length === 0) {
    return (
      <div className="bg-white rounded-3xl border border-gray-100 p-16 text-center shadow-sm">
        <div className="inline-flex items-center justify-center w-24 h-24 rounded-full bg-gray-50 mb-6">
          <Users2 className="h-10 w-10 text-gray-200" />
        </div>
        <h3 className="text-2xl font-black text-gray-900 mb-2">No Students Found</h3>
        <p className="text-gray-500 max-w-sm mx-auto font-medium">
          No records match your filters. Double check your search or add a new student.
        </p>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Mobile Grid View */}
      <div className="grid md:hidden grid-cols-1 gap-4">
        {students.map((student) => (
          <div key={student.id} className="bg-white rounded-4xl p-6 shadow-sm border border-gray-100 hover:shadow-xl hover:shadow-gray-200/50 transition-all duration-300">
            <div className="flex items-center justify-between mb-6">
              <div className="flex items-center gap-4">
                <div className="h-16 w-16 bg-linear-to-br from-teal-500 to-emerald-600 rounded-2xl flex items-center justify-center shadow-lg shadow-teal-100 overflow-hidden ring-4 ring-white">
                  {student.profileImageUrl ? (
                    <img className="h-full w-full object-cover" src={student.profileImageUrl} alt="" />
                  ) : (
                    <span className="text-2xl font-black text-white">{student.name.charAt(0).toUpperCase()}</span>
                  )}
                </div>
                <div>
                  <h4 className="text-lg font-black text-gray-900 leading-tight">{student.name}</h4>
                  <p className="text-xs font-bold text-teal-600 uppercase tracking-widest mt-1">#{student.enrollmentNumber}</p>
                </div>
              </div>
            </div>

            <div className="grid grid-cols-2 gap-y-6 gap-x-4 mb-8">
              <div className="space-y-1">
                <p className="text-[10px] font-black text-gray-400 uppercase tracking-widest flex items-center">
                   <Mail className="h-3 w-3 mr-1" /> Email
                </p>
                <p className="text-sm font-bold text-gray-700 truncate">{student.email}</p>
              </div>
              <div className="space-y-1">
                <p className="text-[10px] font-black text-gray-400 uppercase tracking-widest flex items-center">
                   <Phone className="h-3 w-3 mr-1" /> Phone
                </p>
                <p className="text-sm font-bold text-gray-700 truncate">{formatPhone(student.phone)}</p>
              </div>
              <div className="space-y-1">
                <p className="text-[10px] font-black text-gray-400 uppercase tracking-widest flex items-center">
                   <BookOpen className="h-3 w-3 mr-1" /> Course
                </p>
                <p className="text-sm font-bold text-gray-700 truncate">{student.course}</p>
              </div>
              <div className="space-y-1">
                <p className="text-[10px] font-black text-gray-400 uppercase tracking-widest flex items-center">
                   <Calendar className="h-3 w-3 mr-1" /> Batch
                </p>
                <p className="text-sm font-bold text-gray-700 truncate">{student.batch}</p>
              </div>
            </div>

            <div className="flex gap-3">
              <button 
                onClick={() => onEdit(student)}
                className="flex-2 py-3.5 px-4 bg-teal-600 text-white font-black text-xs uppercase tracking-widest rounded-2xl hover:bg-teal-700 active:scale-95 transition-all shadow-lg shadow-teal-100 flex items-center justify-center gap-2"
              >
                <Edit className="h-4 w-4" /> Edit
              </button>
              <button 
                onClick={() => handleDelete(student)}
                className={cn(
                  "flex-1 py-3.5 px-4 font-black text-xs uppercase tracking-widest rounded-2xl transition-all flex items-center justify-center",
                  deleteConfirmId === student.id
                    ? "bg-red-600 text-white animate-pulse"
                    : "bg-red-50 text-red-600 hover:bg-red-100"
                )}
              >
                {deleteConfirmId === student.id ? 'Sure?' : <Trash2 className="h-4 w-4" />}
              </button>
            </div>
          </div>
        ))}
      </div>

      {/* Modern Desktop Table */}
      <div className="hidden md:block bg-white rounded-[2.5rem] border border-gray-100 shadow-sm overflow-hidden">
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-50">
            <thead className="bg-gray-50/50">
              <tr>
                <th className="px-8 py-6 text-left text-[11px] font-black text-gray-400 uppercase tracking-[0.2em]">Full Identification</th>
                <th className="px-8 py-6 text-left text-[11px] font-black text-gray-400 uppercase tracking-[0.2em]">Communications</th>
                <th className="px-8 py-6 text-left text-[11px] font-black text-gray-400 uppercase tracking-[0.2em]">Academic Program</th>
                <th className="px-8 py-6 text-right text-[11px] font-black text-gray-400 uppercase tracking-[0.2em]">Management</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-50 bg-white">
              {students.map((student) => (
                <tr key={student.id} className="hover:bg-gray-50/30 transition-all group">
                  <td className="px-8 py-5 whitespace-nowrap">
                    <div className="flex items-center">
                      <div className="h-14 w-14 bg-linear-to-br from-teal-500 to-emerald-600 rounded-2xl flex items-center justify-center shadow-lg shadow-teal-100 group-hover:scale-105 transition-transform">
                        {student.profileImageUrl ? (
                          <img className="h-14 w-14 rounded-2xl object-cover" src={student.profileImageUrl} alt="" />
                        ) : (
                          <span className="text-xl font-black text-white">{student.name.charAt(0).toUpperCase()}</span>
                        )}
                      </div>
                      <div className="ml-5">
                        <div className="text-base font-black text-gray-800 tracking-tight">{student.name}</div>
                        <div className="text-[10px] font-black text-teal-600 uppercase tracking-widest mt-1 opacity-70 group-hover:opacity-100">UID: {student.enrollmentNumber}</div>
                      </div>
                    </div>
                  </td>
                  <td className="px-8 py-5 whitespace-nowrap">
                    <div className="space-y-1">
                      <div className="text-sm font-bold text-gray-700 flex items-center">
                        <Mail className="h-3.5 w-3.5 mr-2 text-gray-400" /> {student.email}
                      </div>
                      <div className="text-xs font-medium text-gray-500 flex items-center translate-x-5 px-0.5">
                        {formatPhone(student.phone)}
                      </div>
                    </div>
                  </td>
                  <td className="px-8 py-5 whitespace-nowrap">
                    <div className="flex flex-col gap-1.5">
                      <span className="inline-flex max-w-fit items-center px-3 py-1 rounded-xl text-[10px] font-black uppercase tracking-wider bg-blue-50 text-blue-700 border border-blue-100/50 shadow-sm shadow-blue-50">
                        {student.course}
                      </span>
                      <span className="text-xs font-black text-gray-400 uppercase tracking-widest ml-1">{student.batch} Batch</span>
                    </div>
                  </td>
                  <td className="px-8 py-5 whitespace-nowrap text-right">
                    <div className="flex items-center justify-end gap-3 translate-x-2 opacity-0 group-hover:opacity-100 group-hover:translate-x-0 transition-all duration-300">
                      <button 
                        onClick={() => onEdit(student)}
                        className="p-3 bg-white text-gray-400 hover:text-teal-600 hover:shadow-lg hover:shadow-teal-100 rounded-2xl border border-gray-100 hover:border-teal-100 transition-all"
                      >
                        <Edit className="h-5 w-5" />
                      </button>
                      <button 
                        onClick={() => handleDelete(student)}
                        className={cn(
                          "p-3 rounded-2xl border transition-all",
                          deleteConfirmId === student.id
                            ? "bg-red-600 text-white border-red-600 shadow-xl shadow-red-200"
                            : "bg-white text-gray-400 hover:text-red-500 border-gray-100 hover:border-red-100 hover:shadow-lg hover:shadow-red-50"
                        )}
                      >
                        <Trash2 className="h-5 w-5" />
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}