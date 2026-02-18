import { useState, useEffect } from 'react';
import { 
  Search, 
  Plus, 
  Edit, 
  Trash2, 
  Filter,
  Users as UsersIcon,
  GraduationCap,
  RefreshCw,
  Hash
} from 'lucide-react';
import { studentService } from '../services/students';
import type { Student } from '../types';
import { debounce } from '../utils/helpers';
import StudentModal from '../components/StudentModal';
import StudentTable from '../components/StudentTable';

interface StudentCardProps {
  student: Student;
  onEdit: (student: Student) => void;
  onDelete: (id: string) => void;
}

function StudentCard({ student, onEdit, onDelete }: StudentCardProps) {
  const [showDeleteConfirm, setShowDeleteConfirm] = useState(false);

  const handleDelete = () => {
    if (showDeleteConfirm) {
      onDelete(student.id);
      setShowDeleteConfirm(false);
    } else {
      setShowDeleteConfirm(true);
      setTimeout(() => setShowDeleteConfirm(false), 3000);
    }
  };

  return (
    <div className="bg-white rounded-2xl border border-gray-100 shadow-sm hover:shadow-md transition-all duration-200 overflow-hidden group">
      <div className="p-5">
        <div className="flex items-start justify-between mb-4">
          <div className="flex items-center gap-3">
            <div className="relative">
              <div className="h-11 w-11 bg-linear-to-br from-teal-500 to-blue-600 rounded-xl flex items-center justify-center">
                {student.profileImageUrl ? (
                  <img
                    className="h-11 w-11 rounded-xl object-cover"
                    src={student.profileImageUrl}
                    alt={student.name}
                    onError={(e) => {
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
            </div>
            <div className="min-w-0">
              <h3 className="text-sm font-semibold text-gray-900 truncate" title={student.name}>
                {student.name}
              </h3>
              <p className="text-xs text-gray-500 truncate" title={student.email}>
                {student.email}
              </p>
            </div>
          </div>
          
          <div className="flex items-center gap-1 opacity-0 group-hover:opacity-100 transition-opacity">
            <button
              onClick={() => onEdit(student)}
              className="p-1.5 text-gray-400 hover:text-indigo-600 hover:bg-indigo-50 rounded-lg transition-colors"
              title="Edit"
            >
              <Edit className="h-3.5 w-3.5" />
            </button>
            <button
              onClick={handleDelete}
              className={`p-1.5 rounded-lg transition-colors ${
                showDeleteConfirm
                  ? 'text-red-600 bg-red-50'
                  : 'text-gray-400 hover:text-red-600 hover:bg-red-50'
              }`}
              title={showDeleteConfirm ? 'Confirm' : 'Delete'}
            >
              <Trash2 className={`h-3.5 w-3.5 ${showDeleteConfirm ? 'animate-pulse' : ''}`} />
            </button>
          </div>
        </div>
        
        {/* Details */}
        <div className="space-y-2">
          {student.enrollmentNumber && (
            <div className="flex items-center text-xs text-gray-500">
              <Hash className="h-3.5 w-3.5 mr-1.5 text-gray-400" />
              {student.enrollmentNumber}
            </div>
          )}
          
          <div className="flex items-center gap-2 flex-wrap">
            {student.course && (
              <span className="inline-flex items-center px-2 py-0.5 rounded-md text-[11px] font-medium bg-teal-50 text-teal-700">
                <GraduationCap className="h-3 w-3 mr-1" />
                {student.course}
              </span>
            )}
            {student.batch && (
              <span className="inline-flex items-center px-2 py-0.5 rounded-md text-[11px] font-medium bg-blue-50 text-blue-700">
                {student.batch}
              </span>
            )}
          </div>
        </div>

        {showDeleteConfirm && (
          <p className="text-[11px] text-red-500 mt-2 font-medium">Click again to confirm delete</p>
        )}
      </div>
    </div>
  );
}

export default function StudentsPage() {
  const [students, setStudents] = useState<Student[]>([]);
  const [filteredStudents, setFilteredStudents] = useState<Student[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedCourse, setSelectedCourse] = useState<string>('');
  const [selectedBatch, setSelectedBatch] = useState<string>('');
  const [courses, setCourses] = useState<string[]>([]);
  const [batches, setBatches] = useState<string[]>([]);
  const [viewMode, setViewMode] = useState<'grid' | 'table'>('grid');
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [selectedStudent, setSelectedStudent] = useState<Student | null>(null);

  // Debounced search function
  const debouncedSearch = debounce((query: string) => {
    applyFilters(query, selectedCourse, selectedBatch);
  }, 300);

  const loadStudents = async () => {
    try {
      setIsLoading(true);
      setError(null);
      
      const [studentsData, coursesData, batchesData] = await Promise.all([
        studentService.getStudents(),
        studentService.getCourses(),
        studentService.getBatches()
      ]);
      
      setStudents(studentsData);
      setFilteredStudents(studentsData);
      setCourses(coursesData);
      setBatches(batchesData);
    } catch (err: any) {
      setError(err.message || 'Failed to load students');
    } finally {
      setIsLoading(false);
    }
  };

  const applyFilters = (search: string, course: string, batch: string) => {
    let filtered = students;

    if (search) {
      const searchTerm = search.toLowerCase();
      filtered = filtered.filter(student => 
        student.name.toLowerCase().includes(searchTerm) ||
        student.email.toLowerCase().includes(searchTerm) ||
        student.enrollmentNumber?.toLowerCase().includes(searchTerm)
      );
    }

    if (course) {
      filtered = filtered.filter(student => student.course === course);
    }

    if (batch) {
      filtered = filtered.filter(student => student.batch === batch);
    }

    setFilteredStudents(filtered);
  };

  const handleSearch = (query: string) => {
    setSearchQuery(query);
    debouncedSearch(query);
  };

  const handleCourseFilter = (course: string) => {
    setSelectedCourse(course);
    applyFilters(searchQuery, course, selectedBatch);
  };

  const handleBatchFilter = (batch: string) => {
    setSelectedBatch(batch);
    applyFilters(searchQuery, selectedCourse, batch);
  };

  const clearFilters = () => {
    setSearchQuery('');
    setSelectedCourse('');
    setSelectedBatch('');
    setFilteredStudents(students);
  };

  const handleEdit = (student: Student) => {
    setSelectedStudent(student);
    setIsModalOpen(true);
  };

  const handleDelete = async (id: string) => {
    const student = students.find(s => s.id === id);
    const confirmMessage = `Are you sure you want to delete ${student?.name}?\n\nThis action cannot be undone and will remove:\n- Student profile\n- All attendance records\n- Access to the system`;
    
    if (!window.confirm(confirmMessage)) {
      return;
    }

    try {
      setIsLoading(true);
      await studentService.deleteStudent(id);
      await loadStudents(); // Reload the list
      alert(`${student?.name} has been successfully deleted from the system.`);
    } catch (error: any) {
      alert('Failed to delete student: ' + error.message);
    } finally {
      setIsLoading(false);
    }
  };

  const handleAddStudent = () => {
    setSelectedStudent(null);
    setIsModalOpen(true);
  };

  const handleModalSave = async () => {
    await loadStudents(); // Reload the list after save
  };

  const handleModalClose = () => {
    setIsModalOpen(false);
    setSelectedStudent(null);
  };

  useEffect(() => {
    loadStudents();
  }, []);

  if (isLoading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-teal-600"></div>
        <span className="ml-3 text-gray-600">Loading students...</span>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Page Header */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Students</h1>
          <p className="mt-1 text-sm text-gray-500">
            Manage student records
          </p>
        </div>
        <div className="mt-4 sm:mt-0 flex items-center gap-3">
          <button
            onClick={loadStudents}
            disabled={isLoading}
            className="inline-flex items-center px-4 py-2.5 text-sm font-medium text-gray-700 bg-white border border-gray-200 rounded-xl hover:bg-gray-50 hover:border-gray-300 transition-all"
          >
            <RefreshCw className={`h-4 w-4 mr-2 ${isLoading ? 'animate-spin' : ''}`} />
            Refresh
          </button>
          <button 
            onClick={handleAddStudent}
            className="btn-primary inline-flex items-center"
          >
            <Plus className="h-4 w-4 mr-2" />
            Add Student
          </button>
        </div>
      </div>

      {/* Search & Filters */}
      <div className="bg-white rounded-2xl border border-gray-100 shadow-sm p-4">
        <div className="flex flex-col lg:flex-row lg:items-center gap-3">
          {/* Search */}
          <div className="flex-1">
            <div className="relative">
              <Search className="absolute left-3.5 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400" />
              <input
                type="text"
                value={searchQuery}
                onChange={(e) => handleSearch(e.target.value)}
                className="w-full pl-10 pr-4 py-2.5 text-sm border border-gray-200 rounded-xl bg-gray-50 placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-400 focus:bg-white transition-all"
                placeholder="Search by name, email..."
              />
            </div>
          </div>

          {/* Filters */}
          <div className="flex items-center gap-2">
            <select
              value={selectedCourse}
              onChange={(e) => handleCourseFilter(e.target.value)}
              className="px-3 py-2.5 text-sm border border-gray-200 rounded-xl bg-white focus:outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-400"
            >
              <option value="">All Courses</option>
              {courses.map(course => (
                <option key={course} value={course}>{course}</option>
              ))}
            </select>

            <select
              value={selectedBatch}
              onChange={(e) => handleBatchFilter(e.target.value)}
              className="px-3 py-2.5 text-sm border border-gray-200 rounded-xl bg-white focus:outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-400"
            >
              <option value="">All Batches</option>
              {batches.map(batch => (
                <option key={batch} value={batch}>{batch}</option>
              ))}
            </select>

            {(searchQuery || selectedCourse || selectedBatch) && (
              <button
                onClick={clearFilters}
                className="text-sm text-gray-500 hover:text-gray-700 font-medium px-2"
              >
                Clear
              </button>
            )}
          </div>
        </div>

        {/* Results count */}
        <div className="mt-3 pt-3 border-t border-gray-100 flex items-center justify-between">
          <span className="text-xs text-gray-500">
            {filteredStudents.length} of {students.length} students
          </span>
          
          <div className="flex items-center gap-1">
            <button
              onClick={() => setViewMode('grid')}
              className={`p-1.5 rounded-lg transition-colors ${viewMode === 'grid' ? 'bg-teal-50 text-teal-600' : 'text-gray-400 hover:bg-gray-50'}`}
            >
              <Filter className="h-4 w-4" />
            </button>
            <button
              onClick={() => setViewMode('table')}
              className={`p-1.5 rounded-lg transition-colors ${viewMode === 'table' ? 'bg-teal-50 text-teal-600' : 'text-gray-400 hover:bg-gray-50'}`}
            >
              <UsersIcon className="h-4 w-4" />
            </button>
          </div>
        </div>
      </div>

      {/* Error State */}
      {error && (
        <div className="card p-6 bg-red-50 border border-red-200">
          <p className="text-red-800">{error}</p>
          <button 
            onClick={loadStudents}
            className="mt-2 btn-primary"
          >
            Retry
          </button>
        </div>
      )}

      {/* Students Display */}
      {!error && (
        <>
          {viewMode === 'grid' ? (
            /* Grid View */
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
              {filteredStudents.length > 0 ? (
                filteredStudents.map(student => (
                  <StudentCard
                    key={student.id}
                    student={student}
                    onEdit={handleEdit}
                    onDelete={handleDelete}
                  />
                ))
              ) : (
                <div className="col-span-full">
                  <div className="text-center py-16">
                    <div className="inline-flex items-center justify-center w-14 h-14 rounded-full bg-gray-50 mb-4">
                      <UsersIcon className="h-7 w-7 text-gray-300" />
                    </div>
                    <h3 className="text-base font-medium text-gray-900 mb-1">No students found</h3>
                    <p className="text-sm text-gray-400 mb-5">
                      {searchQuery || selectedCourse || selectedBatch
                        ? 'Try adjusting your filters'
                        : 'Add your first student to get started'}
                    </p>
                    <button 
                      onClick={handleAddStudent}
                      className="btn-primary inline-flex items-center"
                    >
                      <Plus className="h-4 w-4 mr-2" />
                      Add Student
                    </button>
                  </div>
                </div>
              )}
            </div>
          ) : (
            /* Table View */
            <StudentTable
              students={filteredStudents}
              onEdit={handleEdit}
              onDelete={handleDelete}
              isLoading={isLoading}
            />
          )}
        </>
      )}
      {/* Student Modal */}
      <StudentModal
        isOpen={isModalOpen}
        onClose={handleModalClose}
        onSave={handleModalSave}
        student={selectedStudent}
      />    </div>
  );
}