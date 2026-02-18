# Admin Web Panel

A modern React-based admin panel for the Geo-Fenced Attendance System. Built with React, TypeScript, Tailwind CSS, and Vite.

## Features

- **Dashboard**: Real-time attendance statistics and overview
- **Student Management**: Add, edit, search, and manage student records
- **Attendance Tracking**: View and export attendance records with geo-location support
- **Institute Settings**: Configure geo-fence location and admin settings
- **Authentication**: Secure Firebase authentication for administrators
- **Responsive Design**: Works seamlessly on desktop, tablet, and mobile devices
- **Modern UI**: Clean, professional interface built with Tailwind CSS

## Tech Stack

- **Framework**: React 18 with TypeScript
- **Build Tool**: Vite
- **Styling**: Tailwind CSS
- **State Management**: Zustand
- **Data Fetching**: TanStack React Query
- **Routing**: React Router v6
- **Authentication**: Firebase Auth
- **Database**: Cloud Firestore
- **Forms**: React Hook Form with Zod validation
- **Icons**: Lucide React

## Getting Started

### Prerequisites

- Node.js 16+ 
- npm or yarn

### Installation

1. Clone the repository and navigate to the admin-web directory:
```bash
cd admin-web
```

2. Install dependencies:
```bash
npm install
```

3. Update Firebase configuration:
   - The Firebase config is already set up in `src/services/firebase.ts`
   - Make sure your Firebase project has the same configuration as the Flutter app

4. Start the development server:
```bash
npm run dev
```

5. Open [http://localhost:3000](http://localhost:3000) in your browser

### Build for Production

```bash
npm run build
```

The built files will be in the `dist` directory.

## Project Structure

```
src/
├── components/          # Reusable UI components
│   ├── Header.tsx      # Top navigation header
│   ├── MainLayout.tsx  # Main app layout wrapper
│   └── Sidebar.tsx     # Side navigation menu
├── pages/              # Page components
│   ├── AttendancePage.tsx
│   ├── DashboardPage.tsx
│   ├── LoginPage.tsx
│   ├── SettingsPage.tsx
│   └── StudentsPage.tsx
├── services/           # API and external service integrations
│   ├── attendance.ts   # Attendance-related API calls
│   ├── auth.ts        # Authentication service
│   ├── dashboard.ts   # Dashboard statistics
│   ├── firebase.ts    # Firebase configuration
│   └── students.ts    # Student management APIs
├── stores/            # State management
│   └── auth.ts        # Authentication state store
├── types/             # TypeScript type definitions
│   └── index.ts
├── utils/             # Utility functions
│   └── helpers.ts
├── App.tsx            # Main app component with routing
├── main.tsx          # App entry point
└── index.css         # Global styles and Tailwind imports
```

## Key Features

### Dashboard
- Real-time attendance statistics
- Present/absent student counts
- Attendance percentage tracking
- Recent activity feed
- Quick action buttons

### Student Management
- Add new students with enrollment details
- Search and filter students by name, course, batch
- Edit student information
- Delete student records
- Export student data

### Attendance Tracking
- View daily attendance records
- Filter by date, status, and student
- Export attendance to CSV
- Geo-location tracking display
- Status indicators (checked in/out/absent)

### Institute Settings
- Configure institute information
- Set geo-fence location and radius
- Detect current location automatically
- Manage admin email addresses
- Location preview and validation

### Authentication
- Secure admin-only access
- Email/password authentication
- Automatic session management
- Protected route handling

## Firebase Integration

The admin panel integrates with the same Firebase project as the Flutter app:

- **Authentication**: Admin login with role-based access
- **Firestore**: Student and attendance data storage
- **Real-time Updates**: Live data synchronization

## Responsive Design

The admin panel is fully responsive and provides:

- **Desktop**: Full sidebar navigation and multi-column layouts
- **Tablet**: Collapsible sidebar with optimized spacing
- **Mobile**: Hidden sidebar with hamburger menu and stacked layouts

## Development

### Available Scripts

- `npm run dev` - Start development server
- `npm run build` - Build for production
- `npm run preview` - Preview production build
- `npm run lint` - Run ESLint

### Adding New Features

1. Create new page components in `src/pages/`
2. Add corresponding service functions in `src/services/`
3. Update routing in `src/App.tsx`
4. Add navigation links in `src/components/Sidebar.tsx`

### State Management

The app uses Zustand for state management:

- Keep stores small and focused
- Use derived selectors for computed state
- Implement proper error handling

### Styling Guidelines

- Use Tailwind CSS utility classes
- Follow the existing color scheme (purple theme)
- Ensure responsive design with mobile-first approach
- Use the predefined component classes in `index.css`

## Deployment

The admin panel can be deployed to any static hosting service:

1. **Vercel**: Connect your GitHub repository for automatic deployments
2. **Netlify**: Deploy from GitHub or upload the `dist` folder
3. **Firebase Hosting**: Use `firebase deploy` after building
4. **AWS S3**: Upload the `dist` folder to an S3 bucket

Make sure to:
- Set up proper environment variables for production
- Configure Firebase security rules
- Enable HTTPS for secure authentication

## Security

- All routes are protected and require admin authentication
- Firebase security rules should restrict access to admin users only
- Sensitive operations include proper error handling
- Input validation is implemented using Zod schemas

## Contributing

1. Follow the existing code style and patterns
2. Add proper TypeScript types for all new features
3. Implement error handling for all API calls
4. Test responsive design on multiple screen sizes
5. Update this README for any significant changes