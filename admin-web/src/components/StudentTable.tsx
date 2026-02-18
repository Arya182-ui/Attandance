import { useState } from 'react';
import { Trash2, Edit, MapPin, Phone, Mail, GraduationCap, Users2, AlertTriangle, Hash } from 'lucide-react';
import type { Student } from '../types';

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
      // Auto-cancel confirmation after 3 seconds
      setTimeout(() => {
        setDeleteConfirmId(null);
      }, 3000);
    }
  };

  const formatPhone = (phone?: string) => {
    if (!phone) return 'Not provided';
    
    // Format phone number if it's digits only
    const cleaned = phone.replace(/\D/g, '');
    if (cleaned.length === 10) {
      return `(${cleaned.slice(0, 3)}) ${cleaned.slice(3, 6)}-${cleaned.slice(6)}`;
    }
    return phone;
  };

  if (isLoading) {
    return (
      <div className="bg-white rounded-xl shadow-lg overflow-hidden">
        <div className="animate-pulse">
          <div className="h-12 bg-gray-200"></div>
          {[...Array(5)].map((_, i) => (
            <div key={i} className="h-16 bg-gray-100 border-t border-gray-200"></div>
          ))}
        </div>
      </div>
    );
  }

  if (students.length === 0) {
    return (
      <div className="bg-white rounded-xl shadow-lg p-12 text-center">
        <Users2 className="h-16 w-16 mx-auto text-gray-300 mb-4" />
        <h3 className="text-xl font-semibold text-gray-900 mb-2">No Students Found</h3>
        <p className="text-gray-600">
          No students match your current filters. Try adjusting your search criteria or add new students.
        </p>
      </div>
    );
  }

  return (
    <div className="bg-white rounded-xl shadow-lg overflow-hidden">
      <div className="overflow-x-auto">
        <table className="min-w-full divide-y divide-gray-200">
          {/* Table Header */}
          <thead className="bg-linear-to-r from-teal-50 to-blue-50">
            <tr>
              <th className="px-6 py-4 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">
                Student Information
              </th>
              <th className="px-6 py-4 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">
                Contact
              </th>
              <th className="px-6 py-4 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">
                Academic Details
              </th>
              <th className="px-6 py-4 text-center text-xs font-semibold text-gray-700 uppercase tracking-wider">
                Actions
              </th>
            </tr>
          </thead>

          {/* Table Body */}
          <tbody className="bg-white divide-y divide-gray-200">
            {students.map((student, index) => (
              <tr 
                key={student.id} 
                className={`hover:bg-gray-50 transition-colors ${
                  index % 2 === 0 ? 'bg-white' : 'bg-gray-50/30'
                }`}
              >
                {/* Student Information */}
                <td className="px-6 py-4 whitespace-nowrap">
                  <div className="flex items-center">
                    <div className="h-12 w-12 bg-linear-to-br from-teal-500 to-blue-600 rounded-xl flex items-center justify-center shadow-lg">
                      {student.profileImageUrl ? (
                        <img
                          className="h-12 w-12 rounded-xl object-cover"
                          src={student.profileImageUrl}
                          alt={student.name}
                          onError={(e) => {
                            // Fallback to initials if image fails to load
                            const target = e.target as HTMLImageElement;
                            target.style.display = 'none';
                          const nextElement = target.nextElementSibling as HTMLElement;
                          if (nextElement) nextElement.style.display = 'flex';
                          }}
                        />
                      ) : null}
                      <div className={`text-lg font-semibold text-white ${student.profileImageUrl ? 'hidden' : 'flex'} items-center justify-center`}>
                        {student.name.charAt(0).toUpperCase()}
                      </div>
                    </div>
                    <div className="ml-4">
                      <div className="text-lg font-semibold text-gray-900">
                        {student.name}
                      </div>
                      <div className="flex items-center text-sm text-gray-600">
                        <Hash className="h-4 w-4 mr-1" />
                        {student.enrollmentNumber}
                      </div>
                    </div>
                  </div>
                </td>

                {/* Contact Information */}
                <td className="px-6 py-4 whitespace-nowrap">
                  <div className="space-y-2">
                    <div className="flex items-center text-sm text-gray-900">
                      <Mail className="h-4 w-4 mr-2 text-gray-400" />
                      <span className="truncate" title={student.email}>
                        {student.email}
                      </span>
                    </div>
                    <div className="flex items-center text-sm text-gray-600">
                      <Phone className="h-4 w-4 mr-2 text-gray-400" />
                      <span>{formatPhone((student as any).phone)}</span>
                    </div>
                  </div>
                </td>

                {/* Academic Details */}
                <td className="px-6 py-4 whitespace-nowrap">
                  <div className="space-y-2">
                    <div className="flex items-center">
                      <span className="inline-flex items-center px-3 py-1 rounded-full text-xs font-medium bg-blue-100 text-blue-800">
                        <GraduationCap className="h-3 w-3 mr-1" />
                        {student.course}
                      </span>
                    </div>
                    <div className="flex items-center">
                      <span className="inline-flex items-center px-3 py-1 rounded-full text-xs font-medium bg-green-100 text-green-800">
                        Batch: {student.batch}
                      </span>
                    </div>
                  </div>
                </td>

                {/* Actions */}
                <td className="px-6 py-4 whitespace-nowrap text-center">
                  <div className="flex items-center justify-center space-x-2">
                    <button
                      onClick={() => onEdit(student)}
                      className="p-2 text-gray-400 hover:text-indigo-600 hover:bg-indigo-50 rounded-lg transition-all duration-200 group"
                      title="Edit Student"
                    >
                      <Edit className="h-4 w-4 group-hover:scale-110 transition-transform" />
                    </button>
                    
                    <button
                      onClick={() => handleDelete(student)}
                      className={`p-2 rounded-lg transition-all duration-200 group ${
                        deleteConfirmId === student.id
                          ? 'text-red-600 bg-red-100 hover:bg-red-200'
                          : 'text-gray-400 hover:text-red-600 hover:bg-red-50'
                      }`}
                      title={deleteConfirmId === student.id ? 'Confirm Delete' : 'Delete Student'}
                    >
                      {deleteConfirmId === student.id ? (
                        <AlertTriangle className="h-4 w-4 group-hover:scale-110 transition-transform animate-pulse" />
                      ) : (
                        <Trash2 className="h-4 w-4 group-hover:scale-110 transition-transform" />
                      )}
                    </button>
                  </div>
                  
                  {deleteConfirmId === student.id && (
                    <div className="mt-2 text-xs text-red-600 font-medium">
                      Click again to confirm
                    </div>
                  )}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {/* Table Footer */}
      <div className="bg-gray-50 px-6 py-3 border-t border-gray-200">
        <div className="flex items-center justify-between">
          <div className="text-sm text-gray-600">
            Showing {students.length} students
          </div>
          <div className="flex items-center text-xs text-gray-500">
            <MapPin className="h-3 w-3 mr-1" />
            Table view • Click edit to modify • Double-click delete to confirm
          </div>
        </div>
      </div>
    </div>
  );
}