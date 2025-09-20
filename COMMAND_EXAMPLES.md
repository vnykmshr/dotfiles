# Dotfiles Command Examples & Testing Guide

This guide provides example commands to test and explore all the functionality
built into these dotfiles.

## 🚀 Quick Start Test

```bash
# Make the test script executable and run it
chmod +x test-functionality.sh
./test-functionality.sh
```

## 📁 File Operations

### Modern File Listing (eza)

```bash
# Basic listing
ls                    # Enhanced with eza
ll                    # Long format with git info
la                    # Show all files including hidden
lt                    # Tree view (2 levels)

# Advanced eza features
eza --tree --level=3  # Deeper tree
eza --git            # Show git status
eza --long --header  # Detailed view with headers
```

### Better File Viewing (bat)

```bash
# View files with syntax highlighting
cat README.md         # Enhanced with bat
bat config/zsh/zshrc  # Direct bat usage
bat --style=grid file.js  # With grid lines
bat --line-range 1:20 large-file.txt  # Specific lines
```

### Smart File Finding (fd)

```bash
# Find files and directories
fd config             # Find anything named "config"
fd "\.js$"           # Find JavaScript files
fd --type f --size +1m  # Files larger than 1MB
fd --hidden .env      # Include hidden files
fd --exclude node_modules "test"  # Exclude directories
```

## 🔍 Search Operations

### Enhanced Search (ripgrep)

```bash
# Basic searches
rg "function"         # Search for "function" in all files
rg "TODO" --type js   # Find TODOs in JavaScript files
rg -i "error"         # Case insensitive search
rg "pattern" config/  # Search in specific directory

# Advanced searches
rg --stats "import"   # Show search statistics
rg -A3 -B3 "function" # Show 3 lines before/after matches
rg "class.*Component" --type tsx  # Regex patterns
rg_secrets           # Custom function to find secrets
rg_todos             # Custom function to find TODOs
```

### Traditional Search Fallbacks

```bash
# If modern tools aren't available
grep -r "pattern" .   # Recursive grep
find . -name "*.js"   # Traditional find
```

## 🔀 Git Operations

### Basic Git Aliases

```bash
# Status and branching
gs                    # git status
gst                   # git status (alternative)
gb                    # git branch
gco main             # git checkout main

# Staging and committing
ga .                  # git add .
gc -m "message"      # git commit -m "message"
gp                   # git push

# Viewing changes
gd                   # git diff (with delta)
gl                   # git log --oneline
```

### Enhanced Git Workflows

```bash
# Git helper functions
gsave                # Quick save with auto-commit message
gpull                # Smart pull with rebase
gnew feature-branch  # Create and switch to new branch
gswitch main         # Switch branches with safety checks
gclean               # Clean up merged branches
```

### Git Information

```bash
# View git configuration
git config --list | grep user
git config pager.diff    # Should show delta
git log --oneline -5     # Recent commits with delta
```

## 🧠 History & Intelligence

### History Management

```bash
# View and search history
hstats               # Show history statistics
hsearch "git"        # Search command history
htime yesterday      # Commands from yesterday
hfind "npm"          # Find commands containing "npm"

# History cleanup
history_dedupe       # Remove duplicate entries
history_clean_sensitive  # Remove sensitive commands
```

### Smart Suggestions

```bash
# Project-based suggestions
smart_suggest        # Get suggestions for current project type
history_suggest      # AI-powered command suggestions
```

## 🎨 Prompt Features

### Test Prompt Elements

```bash
# Navigate to see prompt changes
cd ~                 # Home directory
cd /tmp              # System directory
cd ~/very/long/path/to/some/deep/directory  # Path truncation

# Git prompt testing (in a git repo)
git status           # See git symbols in prompt
echo "test" > newfile  # Creates ? symbol
git add newfile      # Creates ● symbol
echo "more" >> README.md  # Creates ± symbol
```

### Prompt Configuration

```bash
# Enable/disable features
export DOTFILES_PROMPT_TIME=1  # Show timestamps
export KUBECTL_CONTEXT=dev     # Show k8s context
# Restart shell to see changes
```

## ⚡ Development Automation

### Environment Detection

```bash
# Test environment detection
cd ~/path/to/node/project    # Should detect package.json
cd ~/path/to/python/project  # Should detect .python-version
cd ~/path/to/docker/project  # Should detect Dockerfile

# Manual environment commands
envup                # Refresh environment detection
envinfo             # Show current environment
use_node 18.0.0     # Create .nvmrc file
use_python 3.11     # Create .python-version file
```

### Project Automation

```bash
# Project setup and management
project_setup        # Initialize project structure
dev_server_start     # Start development server
test_run_smart      # Run appropriate tests for project type
```

## 🔒 Security Features

### Sensitive Command Detection

```bash
# Test sensitive pattern detection (safely)
echo "aws configure" | source config/zsh/security-automation
echo "export API_KEY=secret" | source config/zsh/security-automation

# Security functions
check_env_security   # Scan .env files for issues
validate_ssh_keys   # Check SSH key permissions
```

## 🌐 Cross-Platform Features

### macOS Specific

```bash
# Show/hide hidden files in Finder
showfiles
hidefiles

# System operations
emptytrash          # Empty trash securely
lock                # Lock screen
```

### Linux Specific

```bash
# Package management (varies by distro)
update              # Update packages
install package     # Install package
search term         # Search packages
```

## 🔧 System Monitoring

### Performance Testing

```bash
# Measure shell performance
shell_time          # Measure zsh startup time
shell_profile       # Profile current session
startup_analyze     # Analyze startup bottlenecks

# System information
top                 # Enhanced top command
ports               # Show open ports
ping google.com     # Network connectivity
```

### File System Operations

```bash
# Disk usage
df                  # Disk free space
du                  # Directory usage
findbig            # Find largest files

# Process management
ps                  # Process list
psg firefox        # Find processes by name
```

## 🔄 Workflow Examples

### Daily Development Workflow

```bash
# Start of day
cd ~/workspace/project
envup               # Refresh environment
gs                  # Check git status
gpull              # Update from remote

# During development
fd "component"      # Find component files
rg "useState"       # Search for React hooks
bat src/App.js      # View file with highlighting
ga . && gc -m "feat: add new component"  # Commit changes

# End of day
gsave              # Quick save work
gp                 # Push changes
```

### Code Review Workflow

```bash
# Review changes
gd                 # View diff with delta
git log --oneline -10  # Recent commits
rg_todos           # Find remaining TODOs
history_clean_sensitive  # Clean history before sharing
```

### Project Exploration

```bash
# Explore new codebase
lt                 # Tree view of structure
rg_code "main"     # Find main functions
fd "config"        # Find configuration files
rg_docs "setup"    # Find setup documentation
```

## 🐛 Troubleshooting Commands

### Common Issues

```bash
# Check tool availability
check_modern_tools  # Verify all tools installed
which rg           # Check ripgrep location
bat --version      # Verify bat version

# Configuration issues
echo $DOTFILES     # Check environment variable
ls -la ~/.dotfiles # Verify symlink
source ~/.zshrc    # Reload configuration

# Performance issues
shell_time 10      # Measure startup time
DOTFILES_DEBUG=true zsh  # Debug mode
```

### Reset and Repair

```bash
# Reset configurations
rm ~/.config/dotfiles/prompt-choice  # Reset prompt choice
source ~/.zshrc    # Reload configuration

# Reinstall tools (macOS)
brew reinstall bat eza fd ripgrep git-delta zoxide
```

## 📊 Testing Everything

### Comprehensive Test

```bash
# Run the complete test suite
./test-functionality.sh

# Test specific categories
./test-functionality.sh | grep "CLI TOOLS"
./test-functionality.sh | grep "FAILED"
```

### Manual Verification

```bash
# Quick functionality check
ls && cat README.md && rg "function" . && fd "config"

# Git integration check
git log --oneline -5 && git diff HEAD~1

# Prompt check (visual)
cd ~ && cd /tmp && cd - && git status
```

---

## 💡 Pro Tips

1. **Use `tab` completion** extensively - most commands and paths have completion
2. **Check `alias` output** to see all available shortcuts
3. **Use `type command-name`** to see what a command actually does
4. **Run `check_modern_tools`** to verify all tools are working
5. **Use `DOTFILES_DEBUG=true`** for troubleshooting
6. **Check `~/.zsh_history`** for command history persistence

## 🆘 Getting Help

```bash
# Command help
rg --help          # Ripgrep help
bat --help         # Bat help
eza --help         # Eza help

# Dotfiles help
dotfiles --help    # Dotfiles utility help
cat COMMAND_EXAMPLES.md  # This guide
```

This guide covers all major functionality. Run the test script first to identify
any issues, then use these examples to explore and verify specific features!
