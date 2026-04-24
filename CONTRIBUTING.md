# Contributing

Thanks for contributing to the Geo-Fenced Attendance System.

This repository contains two apps:
- `student_app` (Flutter)
- `admin-web` (React + TypeScript)

## Code of Conduct

- Be respectful and constructive.
- Keep feedback specific and actionable.
- Assume good intent.

## Getting Started

```bash
git clone https://github.com/YOUR_USERNAME/Attandance.git
cd Attandance
git checkout -b feature/short-description
```

Install dependencies:

```bash
cd student_app
flutter pub get

cd ../admin-web
npm install
```

## Local Validation Checklist

Before opening a PR, run relevant checks for touched code.

Student app:

```bash
cd student_app
dart format .
flutter analyze
flutter test
```

Admin web:

```bash
cd admin-web
npm run lint
npm run build
```

## Branches and Commits

- Use short, focused branches.
- Keep commits small and descriptive.
- Suggested commit prefixes: `feat`, `fix`, `docs`, `refactor`, `test`, `chore`.

Examples:
- `feat: add attendance status filter`
- `fix: prevent duplicate check-in submission`
- `docs: update firebase setup for admin-web`

## Pull Requests

Include the following in your PR description:
- What changed
- Why it changed
- Any Firebase schema/rules impact
- Screenshots or recordings for UI changes
- Test/validation steps you ran

PR quality expectations:
- Keep scope focused
- Update docs for behavior/config changes
- Add or update tests when logic changes
- Avoid unrelated refactors

## Architecture and Code Style

Student app:
- Follow the existing clean architecture boundaries (`domain`, `data`, `presentation`).
- Keep business logic out of UI widgets.

Admin web:
- Keep page-level logic in `src/pages` and API/Firebase logic in `src/services`.
- Prefer shared types in `src/types` and reusable helpers in `src/utils`.

General:
- Prefer clear names over clever abstractions.
- Add comments only where logic is not obvious.

## Firebase and Security Changes

When a PR changes Firebase behavior:
- Update `firestore.rules` if required.
- Document collection/schema changes in `ARCHITECTURE.md`.
- Document setup changes in `FIREBASE_SETUP.md`.
- Validate role-based access paths manually.

Never commit secrets or credentials.

## Reporting Issues

For bugs, include:
- Reproduction steps
- Expected vs actual behavior
- Device/browser details
- Relevant logs or screenshots

For security issues:
- Do not open a public issue with exploit details.
- Share a private report with maintainers first.

## License

By contributing, you agree your contributions are licensed under MIT.
