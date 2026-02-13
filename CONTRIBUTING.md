# Contributing to Geo-Fenced Attendance System

Thank you for your interest in contributing! This document provides guidelines and instructions for contributing.

## Code of Conduct

- Be respectful and inclusive
- Welcome newcomers
- Focus on constructive feedback
- Maintain professional communication

## How to Contribute

### Reporting Bugs

1. Check if the bug is already reported in Issues
2. Create a new issue with:
   - Clear title
   - Steps to reproduce
   - Expected vs actual behavior
   - Screenshots if applicable
   - Environment details (Flutter version, device, OS)

### Suggesting Features

1. Check existing feature requests
2. Create an issue with:
   - Clear description
   - Use case explanation
   - Proposed implementation (if any)
   - Benefits to users

### Contributing Code

#### Setup Development Environment

```bash
# Fork and clone
git clone https://github.com/YOUR_USERNAME/Attandance.git
cd Attandance

# Create feature branch
git checkout -b feature/your-feature-name

# Install dependencies
cd student_app && flutter pub get
cd ../admin_panel && flutter pub get
```

#### Coding Standards

**Dart/Flutter:**
- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart)
- Use `flutter analyze` before committing
- Run `dart format .` for consistent formatting
- Write meaningful commit messages

**Code Structure:**
- Maintain Clean Architecture layers
- Keep files focused and single-purpose
- Add comments for complex logic
- Update documentation for new features

**Naming Conventions:**
- Classes: `PascalCase`
- Variables/Functions: `camelCase`
- Files: `snake_case.dart`
- Constants: `SCREAMING_SNAKE_CASE`

#### Testing

```bash
# Run tests
flutter test

# Check code coverage
flutter test --coverage

# Analyze code
flutter analyze
```

**Test Requirements:**
- Unit tests for business logic
- Widget tests for UI components
- Integration tests for critical flows

#### Pull Request Process

1. **Before Submitting:**
   - Update documentation
   - Add/update tests
   - Run `flutter analyze` (no errors)
   - Run `dart format .`
   - Test on both platforms (if applicable)

2. **PR Description:**
   - Link related issues
   - Describe changes clearly
   - List breaking changes (if any)
   - Add screenshots for UI changes

3. **PR Title Format:**
   ```
   [Type] Brief description
   
   Types: feat, fix, docs, style, refactor, test, chore
   
   Examples:
   [feat] Add biometric authentication
   [fix] Resolve check-in distance calculation
   [docs] Update deployment guide
   ```

4. **Review Process:**
   - Address reviewer feedback
   - Keep PR scope focused
   - Be responsive to comments
   - Update PR description if needed

## Development Guidelines

### Architecture

Follow Clean Architecture:

```
presentation/ (UI, State Management)
    ↓
domain/ (Business Logic, Use Cases)
    ↓
data/ (Data Sources, Repositories)
```

**Key Principles:**
- Dependency direction: UI → Domain ← Data
- Domain layer is framework-independent
- Use interfaces for abstraction
- Implement dependency injection

### Adding New Features

#### 1. Plan the Feature

- Discuss in Issues first
- Design data models
- Plan UI/UX
- Consider security implications

#### 2. Domain Layer First

```dart
// 1. Create entity (if needed)
class NewEntity { }

// 2. Add repository interface
abstract class NewRepository { }

// 3. Create use case
class NewUseCase { }
```

#### 3. Data Layer

```dart
// 1. Create model
class NewModel extends NewEntity { }

// 2. Implement data source
class NewDataSource { }

// 3. Implement repository
class NewRepositoryImpl implements NewRepository { }
```

#### 4. Presentation Layer

```dart
// 1. Create provider
final newProvider = Provider<NewRepository>(...);

// 2. Create screen/widget
class NewScreen extends ConsumerWidget { }
```

### Firebase Changes

**Firestore Structure Changes:**
1. Document in ARCHITECTURE.md
2. Update security rules
3. Create migration guide (if needed)
4. Test thoroughly

**Security Rules:**
1. Always maintain least privilege
2. Test rules comprehensively
3. Document rule logic
4. Never expose sensitive data

### UI/UX Guidelines

**Design Principles:**
- Material Design 3
- Consistent spacing (8px grid)
- Accessible color contrast
- Responsive layouts
- Loading states
- Error handling

**Colors:**
- Primary: Deep Purple
- Success: Green
- Error: Red
- Warning: Orange

**Components:**
- Use built-in Material widgets
- Create reusable custom widgets
- Maintain consistent styling

### Performance

**Best Practices:**
- Minimize Firestore reads
- Use pagination for lists
- Implement caching
- Optimize images
- Lazy load when possible

**Monitoring:**
- Add logging for errors
- Track performance metrics
- Monitor Firebase usage

## Documentation

### Required Documentation

**For New Features:**
- Update README.md
- Add to FEATURES.md
- Update ARCHITECTURE.md (if structure changes)
- Code comments for complex logic
- Update QUICKSTART.md (if setup changes)

**For Bug Fixes:**
- Document the issue
- Explain the solution
- Add test to prevent regression

### Documentation Style

- Clear and concise
- Include code examples
- Add screenshots for UI
- Keep up-to-date

## Security

**Security Guidelines:**
- Never commit API keys
- Review security rules carefully
- Validate all user inputs
- Use secure authentication
- Follow least privilege principle

**Reporting Security Issues:**
1. Do NOT create public issue
2. Email: [your-security-email]
3. Include detailed description
4. Wait for response before disclosure

## Release Process

### Version Numbering

Follow [Semantic Versioning](https://semver.org/):
- MAJOR.MINOR.PATCH
- Example: 1.2.3

**Incrementing:**
- MAJOR: Breaking changes
- MINOR: New features (backward compatible)
- PATCH: Bug fixes

### Release Checklist

- [ ] Update version numbers
- [ ] Update CHANGELOG.md
- [ ] Run all tests
- [ ] Update documentation
- [ ] Create release notes
- [ ] Tag release in Git
- [ ] Deploy to production

## Communication

### Channels

- **Issues**: Bug reports, feature requests
- **Pull Requests**: Code contributions
- **Discussions**: General questions, ideas

### Response Times

- We aim to respond within 48 hours
- Complex issues may take longer
- PRs reviewed within one week

## Recognition

Contributors are recognized:
- In project README
- In release notes
- GitHub contributors page

## Questions?

- Check documentation first
- Search existing issues
- Create new issue if needed
- Be patient and respectful

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

**Thank you for contributing! 🙏**

Every contribution, no matter how small, helps make this project better.
