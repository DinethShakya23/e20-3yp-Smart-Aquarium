# Contributing to AquaSense

Thank you for your interest in contributing to AquaSense! This document provides guidelines and instructions for contributing to the project.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [How to Contribute](#how-to-contribute)
- [Coding Standards](#coding-standards)
- [Commit Guidelines](#commit-guidelines)
- [Pull Request Process](#pull-request-process)
- [Testing](#testing)
- [Documentation](#documentation)

## Code of Conduct

### Our Standards

- Be respectful and inclusive
- Welcome newcomers and help them learn
- Focus on constructive feedback
- Prioritize the best outcome for the community
- Show empathy towards other contributors

### Unacceptable Behavior

- Harassment or discriminatory language
- Trolling or insulting comments
- Public or private harassment
- Publishing others' private information
- Other unprofessional conduct

## Getting Started

1. **Fork the repository** on GitHub
2. **Clone your fork** locally
   ```bash
   git clone https://github.com/YOUR-USERNAME/e20-3yp-Smart-Aquarium.git
   cd e20-3yp-Smart-Aquarium
   ```
3. **Add upstream remote**
   ```bash
   git remote add upstream https://github.com/cepdnaclk/e20-3yp-Smart-Aquarium.git
   ```
4. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

## Development Setup

### Backend (Node.js)
```bash
cd code/backend
npm install
cp .env.example .env
# Configure .env with your settings
npm run dev
```

### Frontend (Flutter)
```bash
cd code/Frontend
flutter pub get
flutter run
```

### Raspberry Pi Code
```bash
cd code/Rasberry\ pi\ code/
pip3 install -r requirements.txt
```

### Object Tracking
```bash
cd code/object-tracking-yolov8-deep-sort-master
pip install -r requirements.txt
```

## How to Contribute

### Reporting Bugs

Before creating bug reports, please check existing issues to avoid duplicates.

**Good bug reports include:**
- Clear descriptive title
- Steps to reproduce
- Expected vs. actual behavior
- Screenshots if applicable
- Environment details (OS, versions, etc.)
- Error messages and logs

**Template:**
```markdown
## Bug Description
[Clear description of the bug]

## Steps to Reproduce
1. Go to '...'
2. Click on '...'
3. Scroll down to '...'
4. See error

## Expected Behavior
[What you expected to happen]

## Actual Behavior
[What actually happened]

## Environment
- OS: [e.g., Ubuntu 20.04]
- Node.js: [e.g., v14.17.0]
- Flutter: [e.g., v3.0.0]
- Python: [e.g., v3.8.5]

## Additional Context
[Any other relevant information]
```

### Suggesting Enhancements

Enhancement suggestions are welcome! Please provide:
- Clear description of the enhancement
- Why it would be useful
- Possible implementation approach
- Examples from other projects (if applicable)

### Code Contributions

1. **Check existing issues** or create a new one
2. **Discuss your approach** before starting work
3. **Write clean, documented code**
4. **Add tests** for new functionality
5. **Update documentation** as needed
6. **Submit a pull request**

## Coding Standards

### General Principles

- **DRY** (Don't Repeat Yourself)
- **KISS** (Keep It Simple, Stupid)
- **YAGNI** (You Aren't Gonna Need It)
- Write self-documenting code
- Comment complex logic
- Use meaningful variable names

### JavaScript/Node.js (Backend)

```javascript
// Use camelCase for variables and functions
const sensorData = getSensorData();

// Use PascalCase for classes
class SensorController {
  // Use descriptive method names
  async getCurrentReading() {
    // ...
  }
}

// Use const/let, not var
const API_KEY = 'abc123';
let counter = 0;

// Use arrow functions for callbacks
data.map(item => item.value);

// Use async/await instead of callbacks
async function fetchData() {
  try {
    const result = await api.getData();
    return result;
  } catch (error) {
    console.error('Error:', error);
  }
}
```

### Dart/Flutter (Frontend)

```dart
// Use lowerCamelCase for variables and functions
String userName = 'John';

// Use PascalCase for classes
class SensorScreen extends StatefulWidget {
  // ...
}

// Use meaningful widget names
Widget buildSensorCard(SensorData data) {
  return Card(
    child: Text(data.value),
  );
}

// Follow Effective Dart guidelines
// https://dart.dev/guides/language/effective-dart
```

### Python (Hardware Control & Computer Vision)

```python
# Use snake_case for variables and functions
sensor_reading = read_sensor()

# Use PascalCase for classes
class TemperatureSensor:
    def __init__(self):
        pass
    
    def read_temperature(self):
        """Read temperature from sensor."""
        pass

# Use type hints
def calculate_average(values: List[float]) -> float:
    return sum(values) / len(values)

# Follow PEP 8 style guide
# https://www.python.org/dev/peps/pep-0008/
```

### File Organization

```
component/
├── __tests__/          # Tests
├── src/
│   ├── controllers/    # Business logic
│   ├── models/         # Data models
│   ├── routes/         # API routes
│   ├── services/       # External services
│   └── utils/          # Utility functions
├── config/             # Configuration
└── README.md          # Documentation
```

## Commit Guidelines

### Commit Message Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types

- **feat**: New feature
- **fix**: Bug fix
- **docs**: Documentation changes
- **style**: Code style changes (formatting, no logic change)
- **refactor**: Code refactoring
- **test**: Adding or updating tests
- **chore**: Maintenance tasks
- **perf**: Performance improvements

### Examples

```bash
# Good commit messages
feat(backend): add sensor data API endpoint
fix(frontend): resolve login authentication issue
docs(readme): update installation instructions
refactor(sensors): optimize temperature reading logic
test(backend): add unit tests for user controller

# Bad commit messages
update stuff
fix bug
changes
asdf
```

### Commit Message Guidelines

- Use present tense ("add feature" not "added feature")
- Use imperative mood ("move cursor to..." not "moves cursor to...")
- First line should be 50 characters or less
- Reference issues and pull requests when relevant
- Provide context in the body for complex changes

## Pull Request Process

### Before Submitting

- [ ] Code follows project style guidelines
- [ ] Self-review completed
- [ ] Comments added for complex code
- [ ] Documentation updated
- [ ] Tests added/updated
- [ ] All tests pass
- [ ] No merge conflicts with main branch

### Pull Request Template

```markdown
## Description
[Clear description of changes]

## Related Issue
Fixes #[issue number]

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Changes Made
- [List of changes]
- [...]

## Testing
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Manual testing completed

## Screenshots (if applicable)
[Add screenshots]

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Comments added
- [ ] Documentation updated
- [ ] Tests added/updated
- [ ] No breaking changes (or documented)
```

### Review Process

1. **Automated checks** must pass (linting, tests)
2. **Code review** by at least one team member
3. **Address feedback** and make requested changes
4. **Maintainer approval** required for merge
5. **Squash and merge** to keep history clean

### After Merge

- Delete your feature branch
- Update your local repository
- Close related issues

## Testing

### Backend Tests

```bash
cd code/backend
npm test
npm run test:coverage
```

### Frontend Tests

```bash
cd code/Frontend
flutter test
flutter test --coverage
```

### Python Tests

```bash
cd code/object-tracking-yolov8-deep-sort-master
pytest
pytest --cov
```

### Test Guidelines

- Write tests for new features
- Maintain or improve code coverage
- Test edge cases and error conditions
- Use descriptive test names
- Keep tests independent and isolated

## Documentation

### Code Documentation

- Document public APIs
- Explain complex algorithms
- Add examples for usage
- Keep documentation up-to-date

### README Updates

Update README.md when:
- Adding new features
- Changing setup process
- Modifying dependencies
- Updating configuration

### API Documentation

Document API endpoints with:
- Endpoint URL and method
- Request parameters
- Request body schema
- Response format
- Example requests/responses
- Error codes

## Component-Specific Guidelines

### Backend Contributions

- Follow REST API best practices
- Validate input data
- Handle errors gracefully
- Use appropriate HTTP status codes
- Document API endpoints

### Frontend Contributions

- Follow Material Design guidelines
- Ensure responsive design
- Optimize performance
- Test on multiple devices
- Add loading states

### Hardware/IoT Contributions

- Test on actual hardware when possible
- Document pin configurations
- Handle sensor errors
- Implement proper cleanup
- Consider power consumption

### Computer Vision Contributions

- Optimize for performance
- Document model requirements
- Provide evaluation metrics
- Include sample data
- Consider edge deployment

## Getting Help

- **Documentation**: Check README files
- **Issues**: Search existing issues
- **Discussions**: GitHub Discussions
- **Contact**: Team member emails

## Recognition

Contributors will be recognized in:
- README.md contributors section
- Project documentation
- Release notes

Thank you for contributing to AquaSense! 🐟

---

*This contributing guide is adapted from open source best practices and tailored for the AquaSense project.*
