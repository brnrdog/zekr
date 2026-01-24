# Contributing to Zekr

Thank you for your interest in contributing to Zekr! This document provides guidelines and instructions for contributing.

## Getting Started

1. Fork the repository
2. Clone your fork:
   ```bash
   git clone https://github.com/your-username/zekr.git
   cd zekr
   ```
3. Install dependencies:
   ```bash
   npm install
   ```
4. Run the tests to make sure everything works:
   ```bash
   npm test
   ```

## Development Workflow

### Building

```bash
npm run build    # Build the project
npm run watch    # Build in watch mode
npm run clean    # Clean build artifacts
```

### Testing

```bash
npm test         # Build and run all tests
```

Zekr uses itself for testing. Tests are located in the `tests/` directory.

### Project Structure

```
zekr/
├── src/
│   └── Zekr.res       # Main source file
├── tests/
│   ├── ZekrTests.res      # Sync tests
│   └── ZekrAsyncTests.res # Async tests
├── package.json
└── rescript.json
```

## Making Changes

1. Create a new branch for your feature or fix:
   ```bash
   git checkout -b feat/my-feature
   ```

2. Make your changes to `src/Zekr.res`

3. Add tests for new functionality in `tests/ZekrTests.res` or `tests/ZekrAsyncTests.res`

4. Run the tests to ensure everything passes:
   ```bash
   npm test
   ```

5. Commit your changes using [Conventional Commits](https://www.conventionalcommits.org/):
   ```bash
   git commit -m "feat: add new assertion"
   git commit -m "fix: handle edge case in assertEqual"
   ```

## Commit Message Guidelines

We use [Conventional Commits](https://www.conventionalcommits.org/) for automatic versioning and changelog generation.

### Format

```
<type>: <description>

[optional body]
```

### Types

- `feat`: A new feature (triggers minor version bump)
- `fix`: A bug fix (triggers patch version bump)
- `docs`: Documentation changes
- `test`: Adding or updating tests
- `refactor`: Code changes that neither fix bugs nor add features
- `chore`: Maintenance tasks

### Examples

```
feat: add assertDeepEqual assertion
fix: handle empty arrays in combineResults
docs: update README with new assertions
test: add tests for async error handling
```

## Pull Request Process

1. Ensure all tests pass
2. Update documentation if needed
3. Submit a pull request to the `main` branch
4. Describe your changes in the PR description

## Adding New Assertions

When adding a new assertion:

1. Add the function to `src/Zekr.res`
2. Follow the existing pattern:
   ```rescript
   let assertExample = (value: 'a, ~message: option<string>=?): testResult => {
     if /* condition */ {
       Pass
     } else {
       let msg = switch message {
       | Some(m) => m
       | None => "Default error message"
       }
       Fail(msg)
     }
   }
   ```
3. Add tests in `tests/ZekrTests.res`
4. Test both pass and fail cases

## Code Style

- Keep functions simple and focused
- Use descriptive names
- Provide clear error messages with expected vs actual values
- Follow existing patterns in the codebase

## Questions?

Open an issue on [GitHub](https://github.com/brnrdog/zekr/issues) if you have questions or need help.
