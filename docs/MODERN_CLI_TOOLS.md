# Modern CLI Tools Integration

The dotfiles now include enhanced replacements for common command-line tools that provide better performance, features, and user experience.

## Tools Included

### 🔧 **File Operations**
- **eza** → Better `ls` with git integration, icons, and tree view
- **bat** → Better `cat` with syntax highlighting and themes
- **fd** → Better `find` with intuitive syntax and speed
- **ripgrep** → Better `grep` with smart defaults and performance

### 🎨 **Git Enhancement**
- **delta** → Better git diff with side-by-side view and syntax highlighting

### 🧭 **Navigation**
- **zoxide** → Smart `cd` with frequency-based directory jumping

## Installation

### Automatic Installation (Recommended)
Modern CLI tools are automatically installed during setup:

```bash
./install/setup.sh
```

During setup, you'll be prompted:
```
Install modern CLI tools? [Y/n]:
```

Select `Y` to install all tools via mise.

### Manual Installation
If you skipped installation or want to install tools later:

```bash
# Install via mise (recommended)
mise install

# Or install individually
mise use -g eza@latest bat@latest ripgrep@latest fd@latest delta@latest zoxide@latest
```

### Check Tool Status
```bash
# Check which tools are installed
toolcheck
# or
tools
# or
clitools
```

## Usage Examples

### Enhanced File Listing (eza)
```bash
# Basic listing with better defaults
ls

# Detailed listing with git status
ll

# Tree view
lt

# Tree view with git info
ltg
```

### Syntax-Highlighted Viewing (bat)
```bash
# View file with syntax highlighting
cat script.py

# Different styles
batplain file.txt    # No decorations
batgrid file.txt     # Grid layout
batfull file.txt     # All features
```

### Fast Searching (ripgrep)
```bash
# Smart search
grep "function"

# Search in specific file types
rg_code "TODO"       # Search only in code files
rg_docs "install"    # Search only in documentation
rg_config "port"     # Search only in config files
rg_todos             # Find TODO/FIXME comments
```

### Intuitive Finding (fd)
```bash
# Find files
find "*.py"

# Find by type
fdt "script"         # Files only
fdd "config"         # Directories only

# Find with size constraints
fd_large             # Files >100MB
fd_recent            # Modified in last 7 days
```

### Enhanced Git Diffs (delta)
```bash
# Git diffs now use delta automatically
git diff
git show
git log -p

# Compare any two files
diff_files file1.txt file2.txt
```

### Smart Navigation (zoxide)
```bash
# Smart directory jumping
z docs               # Jump to most frequent/recent docs directory
zi                   # Interactive directory selection
project myapp        # Jump to project directory

# Utilities
zt                   # Show top directories
zs                   # Show database stats
zc                   # Clean invalid directories
```

## Fallback Behavior

All tools include graceful fallbacks:

- If modern tools aren't installed, commands fall back to standard versions
- Existing muscle memory and scripts continue to work
- No breaking changes to existing workflows

## Configuration

### Tool-Specific Settings
Configuration files are located in `config/cli-tools/`:

- `eza.conf` - Colors, icons, and display options
- `bat.conf` - Themes and syntax highlighting
- `ripgrep.conf` - Search patterns and colors
- `fd.conf` - Find patterns and filters
- `delta.conf` - Git diff styling
- `zoxide.conf` - Navigation and database management

### Customization
Edit the configuration files to customize behavior:

```bash
# Edit bat theme
export BAT_THEME="GitHub"          # Light theme
export BAT_THEME="Monokai Extended" # Dark theme

# Edit eza options
export EZA_STANDARD_OPTIONS="--color=auto --group-directories-first"

# Edit zoxide behavior
export _ZO_ECHO=1                  # Show directory before jumping
```

## Integration Details

- **Mise Configuration**: Tools defined in `config/mise/config.toml`
- **Zsh Integration**: Loaded via `config/cli-tools/init`
- **Alias System**: Smart aliases in `config/cli-tools/aliases`
- **Git Integration**: Delta configured in git template

## Performance

- **Fast Loading**: CLI tools init loads in ~5ms
- **Lazy Evaluation**: Tools only activate when available
- **Efficient Caching**: Zoxide and completion caching enabled

## Troubleshooting

### Tools Not Found
```bash
# Check tool installation
mise list

# Install missing tools
mise install

# Verify path
echo $PATH | grep mise
```

### Aliases Not Working
```bash
# Reload configuration
source ~/.zshrc

# Check alias definition
which ls
alias ls
```

### Performance Issues
```bash
# Check startup time
DOTFILES_DEBUG=true zsh -l

# Disable specific tools if needed
unalias ls  # Disable eza
unalias cat # Disable bat
```

## Uninstalling

To revert to standard tools:
```bash
# Remove tool installations
mise uninstall eza bat ripgrep fd delta zoxide

# Or disable aliases
unalias ls ll cat grep find
```

The configuration system ensures your environment gracefully falls back to standard tools.