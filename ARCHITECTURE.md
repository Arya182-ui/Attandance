# Architecture

## Overview

The repository is a two-client Firebase application:

- `student_app`: Flutter client used by students.
- `admin-web`: React client used by admins.

Both clients share the same Firebase project and data model.

## High-Level System

```text
Student App (Flutter)        Admin Panel (React)
          \                      /
           \                    /
            \                  /
             Firebase Authentication
                     |
                Cloud Firestore
                     |
               Firebase Storage
```

## Repository Layout

```text
Attandance/
  admin-web/
    src/
      components/
      pages/
      services/
      stores/
      types/
      utils/
  student_app/
    lib/
      data/
      domain/
      presentation/
      main.dart
  firestore.rules
  firebase.json
```

## Student App Architecture (Flutter)

The mobile app follows a layered structure:

- `domain`: core entities and use cases
- `data`: Firebase-backed repository implementations
- `presentation`: screens/widgets/state for UI

Flow:

```text
UI (presentation)
  -> use case/domain logic
  -> repository/data layer
  -> Firebase SDK
```

Key responsibilities:
- Geo-fenced check-in validation
- Check-out updates
- Attendance history display
- Student authentication and profile actions

## Admin Web Architecture (React)

The web panel is feature-oriented:

- `pages`: route-level UI screens
- `components`: shared UI blocks
- `services`: Firebase/Auth/Firestore operations
- `stores`: global state (auth/session)
- `types`: shared TypeScript models
- `utils`: pure helper utilities

Flow:

```text
Route/Page
  -> service call
  -> Firebase JS SDK
  -> Firestore/Auth
```

## Data Model (Firestore)

Main collections:

- `users`
  - user profile and role (`student` or `admin`)
- `institute`
  - institute geo-fence settings (`latitude`, `longitude`, `radius`)
- `attendance`
  - daily check-in/check-out records per student

Attendance records generally include:
- student id
- date/day key
- check-in time/location
- check-out time/location
- status

## Security Model

Security is enforced primarily in `firestore.rules`:

- authenticated users only
- students can read/update only their allowed data
- admins have broader read/write access
- role checks are based on `users/{uid}.role`

## Operational Notes

- Keep schema, rules, and docs in sync when changing Firestore fields.
- Prefer shared naming conventions across both clients.
- Validate business-critical constraints in both client logic and rules.

## When Updating Architecture

Update this file when you change:

- folder layout or app boundaries
- Firestore collections/field contracts
- security or role model
- cross-app data flow assumptions
