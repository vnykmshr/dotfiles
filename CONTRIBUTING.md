# Contributing

Thanks for your interest in contributing to this dotfiles repository!

## Development Setup

```bash
# Clone repository
git clone https://github.com/vnykmshr/dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# Setup development environment (installs pre-commit hooks)
make dev

# Run tests
make test

# Preview changes
make install-dry-run
```

## Making Changes

1. **Fork and create a branch**

   ```bash
   git checkout -b feature/your-feature
   ```

2. **Make your changes**
   - Follow existing code style
   - Keep shell scripts POSIX-compliant where possible
   - Use `set -euo pipefail` in bash scripts
   - Add tests for new functionality

3. **Test thoroughly**

   ```bash
   make quality  # Run all checks (validate, lint, test)
   ```

4. **Commit your changes**
   - Use clear, descriptive commit messages
   - Follow conventional commits format (e.g., `feat:`, `fix:`, `docs:`)
   - Pre-commit hooks will run automatically

5. **Submit a pull request**
   - Describe what and why
   - Link any related issues
   - Ensure CI passes

## Code Quality

This project uses:

- **shellcheck** for shell script linting
- **shfmt** for shell script formatting
- **pre-commit** for automated quality checks
- **GitHub Actions** for CI/CD

Pre-commit hooks run automatically on commit. To run manually:

```bash
pre-commit run --all-files
```

## Guidelines

- **Keep it modular** - separate concerns into focused files
- **Avoid bloat** - only add features with clear value
- **Document changes** - update README and CHANGELOG
- **Test cross-platform** - verify on macOS and Linux if possible
- **Security first** - never commit secrets or personal data

## Questions?

- Check [docs/](./docs/) for architecture and philosophy
- Review [COMMAND_EXAMPLES.md](./COMMAND_EXAMPLES.md) for testing scenarios
- Open an issue for discussion before major changes
