import { NavLink, useLocation } from 'react-router-dom';
import { 
  Home, 
  Users, 
  ClipboardCheck, 
  Settings,
  X,
  LogOut,
  GraduationCap
} from 'lucide-react';
import { useAuthStore } from '../stores/auth';
import { cn } from '../utils/helpers';

const navigation = [
  { name: 'Dashboard', href: '/', icon: Home },
  { name: 'Students', href: '/students', icon: Users },
  { name: 'Attendance', href: '/attendance', icon: ClipboardCheck },
  { name: 'Settings', href: '/settings', icon: Settings },
];

interface SidebarProps {
  isOpen: boolean;
  setIsOpen: (isOpen: boolean) => void;
}

export default function Sidebar({ isOpen, setIsOpen }: SidebarProps) {
  const { signOut } = useAuthStore();
  const location = useLocation();

  const handleSignOut = async () => {
    try {
      await signOut();
    } catch (error) {
      console.error('Sign out error:', error);
    }
  };

  return (
    <>
      {/* Mobile overlay */}
      {isOpen && (
        <div 
          className="lg:hidden fixed inset-0 z-40 bg-black/40 backdrop-blur-sm transition-opacity duration-300"
          onClick={() => setIsOpen(false)}
        />
      )}

      {/* Sidebar */}
      <div className={cn(
        "fixed lg:static inset-y-0 left-0 z-50 w-72 bg-white border-r border-gray-100 flex flex-col transform transition-all duration-300 ease-in-out shadow-2xl lg:shadow-none",
        isOpen ? "translate-x-0" : "-translate-x-full lg:translate-x-0"
      )}>
        <div className="flex flex-col h-full bg-white">
          {/* Logo Section */}
          <div className="flex items-center justify-between h-20 px-6 border-b border-gray-50/80">
            <div className="flex items-center gap-3.5">
              <div className="h-10 w-10 bg-linear-to-br from-teal-600 to-emerald-600 rounded-xl flex items-center justify-center shadow-lg shadow-teal-100 ring-4 ring-teal-50">
                <GraduationCap className="h-6 w-6 text-white" />
              </div>
              <div className="flex flex-col">
                <span className="text-base font-bold text-gray-900 tracking-tight leading-none">
                  SmartCareer
                </span>
                <span className="text-[10px] text-teal-600 font-bold uppercase tracking-widest mt-1">
                  Advisor Panel
                </span>
              </div>
            </div>
            {/* Close button for mobile */}
            <button 
              onClick={() => setIsOpen(false)}
              className="lg:hidden p-2 rounded-xl text-gray-400 hover:bg-gray-50 hover:text-gray-950 transition-colors"
            >
              <X className="h-5 w-5" />
            </button>
          </div>

          {/* Navigation Section */}
          <nav className="flex-1 px-4 py-8 space-y-1.5 overflow-y-auto">
            {navigation.map((item) => {
              const Icon = item.icon;
              const isActive = location.pathname === item.href;
              
              return (
                <NavLink
                  key={item.name}
                  to={item.href}
                  onClick={() => setIsOpen(false)}
                  className={cn(
                    "group flex items-center px-4 py-3 text-sm font-semibold rounded-xl transition-all duration-200 relative",
                    isActive
                      ? "bg-teal-50/80 text-teal-700 shadow-sm shadow-teal-50"
                      : "text-gray-500 hover:bg-gray-50/80 hover:text-gray-900"
                  )}
                >
                  <Icon className={cn(
                    "h-5 w-5 mr-3.5 transition-colors",
                    isActive ? "text-teal-600" : "text-gray-400 group-hover:text-gray-600"
                  )} />
                  {item.name}
                  {isActive && (
                    <div className="absolute left-0 w-1 h-6 bg-teal-600 rounded-r-full" />
                  )}
                </NavLink>
              );
            })}
          </nav>

          {/* Footer Section */}
          <div className="p-4 border-t border-gray-50/80">
            <button
              onClick={handleSignOut}
              className="flex items-center w-full px-4 py-3.5 text-sm font-semibold text-red-500 rounded-xl hover:bg-red-50/80 transition-all duration-200 group"
            >
              <LogOut className="h-5 w-5 mr-3.5 transition-transform group-hover:-translate-x-1" />
              Sign Out
            </button>
          </div>
        </div>
      </div>
    </>
  );
}