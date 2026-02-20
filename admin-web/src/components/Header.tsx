import { User, Search, Menu, Bell } from 'lucide-react';
import { useAuthState } from '../stores/auth';

interface HeaderProps {
  onMenuClick: () => void;
}

export default function Header({ onMenuClick }: HeaderProps) {
  const { user } = useAuthState();

  return (
    <header className="bg-white/80 backdrop-blur-md border-b border-gray-100 sticky top-0 z-30">
      <div className="px-4 sm:px-6 py-3.5">
        <div className="flex items-center justify-between gap-4">
          {/* Mobile Menu Button */}
          <button
            onClick={onMenuClick}
            className="lg:hidden p-2.5 -ml-2 rounded-xl text-gray-500 hover:bg-gray-50 active:scale-95 transition-all"
          >
            <Menu className="h-6 w-6" />
          </button>

          {/* Search Bar */}
          <div className="hidden md:flex flex-1 max-w-md">
            <div className="relative w-full group">
              <Search className="absolute left-3.5 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400 group-focus-within:text-teal-500 transition-colors" />
              <input
                type="text"
                className="w-full pl-10 pr-4 py-2 text-sm border border-gray-200 rounded-xl bg-gray-50/50 placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-teal-500/10 focus:border-teal-400 focus:bg-white transition-all shadow-sm"
                placeholder="Search anything..."
              />
            </div>
          </div>

          {/* Right side */}
          <div className="flex items-center gap-2 sm:gap-4 ml-auto">
            <button className="hidden sm:flex p-2 rounded-xl text-gray-400 hover:bg-gray-50 transition-colors">
              <Bell className="h-5 w-5" />
            </button>

            {/* User */}
            <div className="flex items-center gap-2.5 pl-2 sm:pl-4 sm:border-l border-gray-100">
              <div className="hidden sm:block text-right">
                <p className="text-sm font-bold text-gray-800 leading-tight">
                  {user?.name || 'Admin'}
                </p>
                <p className="text-[10px] text-gray-400 font-bold uppercase tracking-wider">Super Admin</p>
              </div>
              <div className="h-9 w-9 rounded-xl bg-linear-to-br from-teal-500 to-emerald-600 flex items-center justify-center shadow-sm shadow-teal-100 ring-2 ring-teal-50">
                <User className="h-4.5 w-4.5 text-white" />
              </div>
            </div>
          </div>
        </div>
      </div>
    </header>
  );
}