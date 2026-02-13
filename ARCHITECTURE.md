# Project Structure

## Overview

This project consists of two Flutter applications:
1. **Student App** - Mobile application for students
2. **Admin Panel** - Web application for administrators

Both follow Clean Architecture principles with clear separation of concerns.

## Directory Structure

```
Attandance/
├── student_app/              # Student mobile application
│   └── lib/
│       ├── core/             # Core utilities and constants
│       │   ├── constants/    # App constants
│       │   ├── theme/        # Theme configuration
│       │   └── utils/        # Helper utilities
│       ├── data/             # Data layer
│       │   ├── datasources/  # Firebase data sources
│       │   │   ├── auth_datasource.dart
│       │   │   ├── attendance_datasource.dart
│       │   │   └── institute_datasource.dart
│       │   ├── models/       # Data models
│       │   │   ├── user_model.dart
│       │   │   ├── attendance_model.dart
│       │   │   └── institute_model.dart
│       │   └── repositories/ # Repository implementations
│       │       ├── auth_repository_impl.dart
│       │       ├── attendance_repository_impl.dart
│       │       └── institute_repository_impl.dart
│       ├── domain/           # Business logic layer
│       │   ├── entities/     # Domain entities
│       │   │   ├── user_entity.dart
│       │   │   ├── attendance_entity.dart
│       │   │   └── institute_entity.dart
│       │   ├── repositories/ # Repository interfaces
│       │   │   ├── auth_repository.dart
│       │   │   ├── attendance_repository.dart
│       │   │   └── institute_repository.dart
│       │   └── usecases/     # Business use cases
│       │       ├── sign_in_usecase.dart
│       │       ├── check_in_usecase.dart
│       │       └── check_out_usecase.dart
│       ├── presentation/     # UI layer
│       │   ├── providers/    # Riverpod state providers
│       │   │   ├── providers.dart
│       │   │   ├── auth_provider.dart
│       │   │   └── attendance_provider.dart
│       │   ├── screens/      # UI screens
│       │   │   ├── login_screen.dart
│       │   │   ├── home_screen.dart
│       │   │   └── attendance_history_screen.dart
│       │   └── widgets/      # Reusable widgets
│       │       └── loading_indicator.dart
│       └── main.dart          # App entry point
│
├── admin_panel/              # Admin web application
│   └── lib/
│       ├── core/             # Core utilities
│       ├── data/             # Data layer
│       │   ├── datasources/
│       │   │   ├── admin_auth_datasource.dart
│       │   │   ├── student_datasource.dart
│       │   │   ├── admin_attendance_datasource.dart
│       │   │   └── admin_institute_datasource.dart
│       │   ├── models/
│       │   │   ├── user_model.dart
│       │   │   ├── attendance_model.dart
│       │   │   └── institute_model.dart
│       │   └── repositories/
│       │       ├── admin_auth_repository_impl.dart
│       │       ├── student_repository_impl.dart
│       │       ├── admin_attendance_repository_impl.dart
│       │       └── admin_institute_repository_impl.dart
│       ├── domain/           # Business logic
│       │   ├── entities/
│       │   │   ├── user_entity.dart
│       │   │   ├── attendance_entity.dart
│       │   │   └── institute_entity.dart
│       │   └── repositories/
│       │       ├── admin_auth_repository.dart
│       │       ├── student_repository.dart
│       │       ├── admin_attendance_repository.dart
│       │       └── admin_institute_repository.dart
│       ├── presentation/     # UI layer
│       │   ├── providers/
│       │   │   ├── providers.dart
│       │   │   ├── admin_auth_provider.dart
│       │   │   ├── student_provider.dart
│       │   │   ├── admin_attendance_provider.dart
│       │   │   └── institute_provider.dart
│       │   ├── screens/
│       │   │   ├── admin_login_screen.dart
│       │   │   ├── dashboard_screen.dart
│       │   │   ├── students_screen.dart
│       │   │   ├── attendance_screen.dart
│       │   │   └── institute_settings_screen.dart
│       │   └── widgets/
│       └── main.dart
│
├── firestore.rules           # Firestore security rules
├── storage.rules             # Storage security rules
├── FIREBASE_SETUP.md         # Firebase setup guide
├── ARCHITECTURE.md           # Architecture documentation
└── README.md                 # Main documentation
```

## Layer Responsibilities

### Domain Layer (Business Logic)
- **Entities**: Pure Dart classes representing business objects
- **Repositories**: Abstract interfaces defining data operations
- **Use Cases**: Specific business logic operations

**Example**: `CheckInUseCase`
- Validates student hasn't already checked in
- Gets institute settings
- Validates location is within radius
- Performs check-in operation

### Data Layer
- **Data Sources**: Direct Firebase interaction
- **Models**: Data transfer objects with serialization
- **Repository Implementations**: Concrete implementations of domain repositories

**Example**: `AttendanceDataSource`
- Handles all Firestore operations for attendance
- Converts between Firestore documents and models

### Presentation Layer
- **Providers**: Riverpod state management
- **Screens**: Full-page UI components
- **Widgets**: Reusable UI components

**Example**: `HomeScreen`
- Displays user info and today's attendance status
- Provides check-in/check-out buttons
- Shows loading and error states

## Key Design Patterns

### Repository Pattern
Abstracts data sources from business logic:
```dart
// Interface (domain)
abstract class AttendanceRepository {
  Future<void> checkIn(...);
}

// Implementation (data)
class AttendanceRepositoryImpl implements AttendanceRepository {
  final AttendanceDataSource _dataSource;
  Future<void> checkIn(...) => _dataSource.checkIn(...);
}
```

### Dependency Injection
Using Riverpod for clean DI:
```dart
final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  return AttendanceRepositoryImpl(ref.watch(attendanceDataSourceProvider));
});
```

### Use Case Pattern
Encapsulates business logic:
```dart
class CheckInUseCase {
  final AttendanceRepository _repository;
  final InstituteRepository _instituteRepository;
  
  Future<void> call(String studentId) async {
    // Business logic here
  }
}
```

## Data Flow

### Student Check-In Flow
```
User Action (UI)
    ↓
Provider (Presentation)
    ↓
Use Case (Domain)
    ↓
Repository (Domain Interface)
    ↓
Repository Implementation (Data)
    ↓
Data Source (Data)
    ↓
Firebase/Firestore
```

### Admin Student Management Flow
```
User Action (UI)
    ↓
Provider (Presentation)
    ↓
Repository (Domain Interface)
    ↓
Repository Implementation (Data)
    ↓
Data Source (Data)
    ↓
Firebase/Firestore + Auth
```

## State Management

### Riverpod Providers

#### Stream Providers
For real-time data:
```dart
final authStateProvider = StreamProvider<UserEntity?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});
```

#### Future Providers
For one-time async data:
```dart
final attendanceHistoryProvider = FutureProvider.family<List<AttendanceEntity>, String>((ref, studentId) {
  return ref.watch(attendanceRepositoryProvider).getAttendanceHistory(studentId);
});
```

#### StateNotifier Providers
For mutable state:
```dart
class AuthNotifier extends StateNotifier<AsyncValue<UserEntity?>> {
  Future<void> signIn(String email, String password) async { ... }
}
```

## Code Organization Best Practices

1. **One class per file** - Each entity, model, or use case in its own file
2. **Clear naming conventions** - Descriptive names indicating purpose
3. **Separation of concerns** - Each layer handles specific responsibilities
4. **Dependency direction** - Always flows inward (UI → Domain ← Data)
5. **Interface segregation** - Small, focused repository interfaces

## Testing Strategy

### Unit Tests
- Test use cases in isolation
- Test repository implementations
- Test data models serialization

### Widget Tests
- Test individual screens
- Test widget interactions
- Test error states

### Integration Tests
- Test complete user flows
- Test Firebase integration
- Test location services

## Adding New Features

When adding a new feature:

1. **Start with Domain**
   - Create entity if needed
   - Add methods to repository interface
   - Create use case

2. **Implement Data Layer**
   - Update data source
   - Update model if needed
   - Implement repository method

3. **Update Presentation**
   - Create/update provider
   - Update UI screens
   - Handle loading/error states

Example: Adding "Late Check-In" feature
1. Domain: Add `isLate` to AttendanceEntity
2. Domain: Update CheckInUseCase to check time
3. Data: Update AttendanceModel serialization
4. Data: Update AttendanceDataSource
5. Presentation: Update UI to show late indicator

## Performance Considerations

- Use `.limit()` on Firestore queries
- Implement pagination for large lists
- Cache institute settings locally
- Optimize image uploads (if using selfies)
- Use indexed queries in Firestore

## Security Considerations

- Never expose Firebase API keys in code
- Use Firestore security rules
- Validate all inputs
- Encrypt sensitive data
- Implement proper error handling
