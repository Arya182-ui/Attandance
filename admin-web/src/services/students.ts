import { 
  collection, 
  getDocs, 
  doc, 
  getDoc, 
  addDoc,
  setDoc,
  updateDoc, 
  deleteDoc,
  query,
  where,
  orderBy
} from 'firebase/firestore';
import { db } from './firebase';
import type { Student, StudentFilters } from '../types';

class StudentService {
  private readonly collectionName = 'users';

  // Get all students
  async getStudents(filters?: StudentFilters): Promise<Student[]> {
    try {
      let q = query(
        collection(db, this.collectionName),
        where('role', '==', 'student'),
        orderBy('name')
      );

      const snapshot = await getDocs(q);
      
      let students = snapshot.docs.map(doc => {
        const data = doc.data();
        return {
          id: doc.id,
          ...data
        };
      }) as Student[];

      // Apply client-side filters
      if (filters?.search) {
        const searchTerm = filters.search.toLowerCase();
        students = students.filter(student => 
          student.name.toLowerCase().includes(searchTerm) ||
          student.email.toLowerCase().includes(searchTerm) ||
          student.enrollmentNumber?.toLowerCase().includes(searchTerm)
        );
      }

      if (filters?.course) {
        students = students.filter(student => student.course === filters.course);
      }

      if (filters?.batch) {
        students = students.filter(student => student.batch === filters.batch);
      }

      return students;
    } catch (error) {
      console.error('Error fetching students:', error);
      throw new Error('Failed to fetch students');
    }
  }

  // Get student by ID
  async getStudentById(id: string): Promise<Student | null> {
    try {
      const docRef = doc(db, this.collectionName, id);
      const docSnap = await getDoc(docRef);
      
      if (docSnap.exists() && docSnap.data().role === 'student') {
        return {
          id: docSnap.id,
          ...docSnap.data()
        } as Student;
      }
      
      return null;
    } catch (error) {
      console.error('Error fetching student:', error);
      throw new Error('Failed to fetch student');
    }
  }

  // Add new student
  // If uid is provided (from Firebase Auth), uses it as the document ID
  // This ensures the Firestore doc ID matches the student's Auth UID
  async addStudent(studentData: Omit<Student, 'id'>, uid?: string): Promise<string> {
    try {
      const data = {
        ...studentData,
        role: 'student',
        createdAt: new Date(),
        updatedAt: new Date()
      };
      
      if (uid) {
        // Use the Firebase Auth UID as the document ID for consistency
        const docRef = doc(db, this.collectionName, uid);
        await setDoc(docRef, data);
        return uid;
      } else {
        // Auto-generate ID (for cases where Auth user hasn't been created yet)
        const docRef = await addDoc(collection(db, this.collectionName), data);
        return docRef.id;
      }
    } catch (error) {
      console.error('Error adding student:', error);
      throw new Error('Failed to add student');
    }
  }

  // Update student
  async updateStudent(id: string, updates: Partial<Student>): Promise<void> {
    try {
      const docRef = doc(db, this.collectionName, id);
      await updateDoc(docRef, {
        ...updates,
        updatedAt: new Date()
      });
    } catch (error) {
      console.error('Error updating student:', error);
      throw new Error('Failed to update student');
    }
  }

  // Delete student
  async deleteStudent(id: string): Promise<void> {
    try {
      const docRef = doc(db, this.collectionName, id);
      await deleteDoc(docRef);
    } catch (error) {
      console.error('Error deleting student:', error);
      throw new Error('Failed to delete student');
    }
  }

  // Get unique courses
  async getCourses(): Promise<string[]> {
    try {
      const students = await this.getStudents();
      const courses = [...new Set(students.map(s => s.course).filter(Boolean))];
      return courses.sort();
    } catch (error) {
      console.error('Error fetching courses:', error);
      return [];
    }
  }

  // Get unique batches  
  async getBatches(): Promise<string[]> {
    try {
      const students = await this.getStudents();
      const batches = [...new Set(students.map(s => s.batch).filter(Boolean))];
      return batches.sort();
    } catch (error) {
      console.error('Error fetching batches:', error);
      return [];
    }
  }
}

export const studentService = new StudentService();