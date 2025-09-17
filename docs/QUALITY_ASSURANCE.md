# Quality Assurance

> Comprehensive testing, validation, and formatting for professional dotfiles

This dotfiles collection includes a robust quality assurance system to ensure reliability, consistency, and maintainability.

## 🧪 **Testing Framework**

### **Test Categories**

#### 1. **Installation Tests** (`tests/test-install.sh`)
- **Dry-run validation**: Tests installation without making changes
- **Actual installation**: Verifies symlinks, directories, and file creation
- **Configuration loading**: Ensures zsh config loads without errors
- **Backup functionality**: Tests that existing files are properly backed up
- **Utility scripts**: Validates workflow helpers and dotfiles manager

#### 2. **Configuration Tests** (`tests/test-configs.sh`)
- **Syntax validation**: Checks zsh, bash, lua, and other config syntax
- **Git configuration**: Validates git config structure and aliases
- **Security checks**: Scans for hardcoded credentials or sensitive data
- **File structure**: Ensures required configuration files exist
- **Alias/function validation**: Checks for proper alias and function syntax

#### 3. **Lint Tests** (`tests/lint-scripts.sh`)
- **ShellCheck**: Static analysis for shell scripts
- **Code formatting**: Validates consistent formatting with shfmt
- **Best practices**: Checks for proper shebangs, error handling, quoting
- **Portability**: Ensures scripts work across different systems
- **Security**: Validates file permissions and checks for common issues

#### 4. **Format Checks** (`tests/format-check.sh`)
- **Consistent styling**: Enforces EditorConfig standards
- **Line endings**: Ensures consistent LF line endings
- **Trailing whitespace**: Removes trailing spaces
- **File structure**: Validates JSON, YAML, Markdown formatting
- **Auto-fix capability**: Can automatically fix many formatting issues

### **Running Tests**

```bash
# Run all tests
make test

# Run specific test categories
make test-configs      # Configuration validation
make test-install      # Installation testing
make lint              # Shell script linting
make format            # Format checking

# Run complete quality check
make quality

# Auto-fix issues
make fix-all
```

### **Test Results**

Tests provide detailed output with:
- ✅ **Pass/Fail status** for each check
- 🔧 **Auto-fix suggestions** for common issues
- 📊 **Summary statistics** showing test coverage
- 🚨 **Error details** for debugging failures

## 🔍 **Validation System**

### **Structure Validation**
- Required files and directories exist
- Executable permissions are correct
- Symlinks point to valid targets
- Configuration files are properly formatted

### **Security Validation**
- No hardcoded credentials or secrets
- Proper file permissions (not world-writable)
- No sensitive data in version control
- Secure defaults in configurations

### **Cross-Platform Validation**
- Works on macOS, Linux, and WSL2
- Package manager compatibility
- Shell compatibility (bash/zsh)
- Path handling across different systems

## 🎨 **Code Formatting**

### **Formatting Standards**

#### **Shell Scripts**
- **Indentation**: 4 spaces (no tabs)
- **Line length**: Reasonable limits with exceptions for URLs
- **Quoting**: Proper variable quoting for security
- **Style**: Consistent with Google Shell Style Guide

#### **Configuration Files**
- **YAML**: 2-space indentation
- **JSON**: 2-space indentation, properly formatted
- **Lua**: 4-space indentation (Neovim config)
- **Markdown**: Consistent formatting, proper line breaks

#### **EditorConfig**
The project includes `.editorconfig` for consistent formatting across editors:

```ini
# All files
[*]
charset = utf-8
end_of_line = lf
insert_final_newline = true
trim_trailing_whitespace = true
indent_style = space
indent_size = 4
```

### **Auto-Formatting**

```bash
# Check formatting
make format

# Auto-fix formatting issues
make format-fix

# Fix linting issues
make lint-fix

# Fix all issues at once
make fix-all
```

## 🔄 **Continuous Integration**

### **GitHub Actions Pipeline** (`.github/workflows/ci.yml`)

The CI pipeline runs automatically on:
- **Push** to main branches
- **Pull requests**
- **Manual triggers**

#### **CI Jobs**

1. **Lint and Format Check**
   - Shell script linting with ShellCheck
   - Format validation
   - Security scanning

2. **Installation Tests**
   - Multi-OS testing (Ubuntu, macOS)
   - Dry-run validation
   - Full installation testing

3. **Structure Validation**
   - Required files check
   - Makefile target validation
   - Documentation completeness

4. **Shell Compatibility**
   - bash/zsh compatibility testing
   - Cross-shell script validation

5. **Security Scan**
   - File permission checks
   - Sensitive data scanning
   - Security best practices validation

6. **Integration Tests**
   - Full installation workflow
   - Alias and function testing
   - Workflow helper validation

7. **Performance Benchmark**
   - Shell startup time measurement
   - Performance regression detection

### **CI Status Badges**

Add to your repository README:

```markdown
[![CI](https://github.com/vnykmshr/dotfiles/workflows/CI/badge.svg)](https://github.com/vnykmshr/dotfiles/actions)
```

## 🪝 **Pre-commit Hooks**

### **Installation**

```bash
# Setup pre-commit hooks
make pre-commit-setup

# Or manually
./install/setup-pre-commit.sh
```

### **Hook Categories**

#### **Built-in Hooks**
- **File checks**: Trailing whitespace, end-of-file-fixer
- **Format validation**: YAML, JSON, TOML syntax
- **Security**: Private key detection, large file prevention
- **Text formatting**: Line ending normalization

#### **Shell Script Hooks**
- **shfmt**: Automatic shell script formatting
- **ShellCheck**: Shell script linting and analysis

#### **Markdown Hooks**
- **markdownlint**: Markdown style and format checking

#### **Custom Hooks**
- **Structure validation**: Dotfiles structure checks
- **Configuration testing**: Config file validation
- **Hardcoded path detection**: Prevents non-portable paths
- **Alias conflict detection**: Warns about system command conflicts
- **Function naming**: Enforces naming conventions

### **Hook Management**

```bash
# Run all hooks manually
pre-commit run --all-files

# Run specific hook
pre-commit run shellcheck

# Update hook versions
pre-commit autoupdate

# Skip hooks (emergency only)
git commit --no-verify

# Skip specific hook
SKIP=shellcheck git commit
```

## 📈 **Quality Metrics**

### **Test Coverage**
- **Shell scripts**: 100% linted with ShellCheck
- **Configurations**: All syntax validated
- **Installation**: Multi-platform tested
- **Security**: Comprehensive scanning

### **Code Quality Standards**
- **Shell scripts**: Pass ShellCheck with minimal exceptions
- **Formatting**: Consistent across all files
- **Documentation**: All major features documented
- **Error handling**: Proper error handling in scripts

### **Performance Standards**
- **Shell startup**: < 2 seconds for zsh initialization
- **Installation**: Completes in reasonable time
- **Test execution**: Fast feedback for development

## 🛠 **Development Workflow**

### **Before Committing**
1. **Run quality checks**: `make quality`
2. **Fix any issues**: `make fix-all`
3. **Test changes**: `make test`
4. **Commit**: Pre-commit hooks run automatically

### **Adding New Features**
1. **Write tests first** (when applicable)
2. **Follow existing patterns** and conventions
3. **Update documentation** as needed
4. **Ensure all quality checks pass**

### **Troubleshooting**

#### **Common Issues**

**ShellCheck failures:**
```bash
# View specific issues
make lint

# Auto-fix formatting
make lint-fix
```

**Format issues:**
```bash
# Check formatting
make format

# Auto-fix
make format-fix
```

**Test failures:**
```bash
# Run specific test
./tests/test-configs.sh

# Keep test environment for debugging
./tests/test-install.sh --keep-test-env
```

#### **Disabling Checks**

For special cases, you can disable specific checks:

```bash
# Disable ShellCheck rule
# shellcheck disable=SC2034
UNUSED_VAR="example"

# Skip pre-commit hook
SKIP=shellcheck git commit
```

## 🎯 **Quality Goals**

- **Reliability**: All installations work consistently
- **Maintainability**: Code is clean and well-documented
- **Security**: No security vulnerabilities or data leaks
- **Performance**: Fast installation and shell startup
- **Compatibility**: Works across platforms and environments
- **Usability**: Clear error messages and documentation

This quality assurance system ensures the dotfiles collection remains professional, reliable, and maintainable as it grows and evolves.