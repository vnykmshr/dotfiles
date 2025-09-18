# Project Overview

> Professional dotfiles designed for customization, not copy-paste

## Philosophy

**Build your development identity, don't copy mine.**

This project provides a solid foundation and practical examples. The real value comes from understanding the patterns and adapting them to your unique workflow. Great developers don't just copy configurations—they understand, modify, and evolve them.

## Design Principles

### 1. **Template-Based Configuration**

- Configuration files are templates, not rigid prescriptions
- Personal data (name, email, SSH keys) separated from versioned configs
- Easy to adapt without breaking the core system

### 2. **Modular Architecture**

```
config/
├── zsh/          # Shell environment and functions
├── git/          # Version control templates and aliases
├── nvim/         # Editor configuration
├── tmux/         # Terminal multiplexer setup
├── ssh/          # SSH client configuration templates
└── workflow/     # Development automation tools
```

### 3. **Progressive Enhancement**

- Works out-of-the-box with sensible defaults
- Each component is optional and independently configurable
- Graceful fallbacks when tools aren't available

### 4. **Professional Quality**

- Clean, maintainable code following industry standards
- Comprehensive test coverage ensuring reliability
- Cross-platform compatibility (macOS, Linux, WSL)

## What's Actually Implemented

### Shell Environment (Zsh)

**What you get**:

- Fast startup (0.158s) with lazy loading
- Smart completion system with caching
- Cross-platform compatibility (macOS, Linux, WSL)
- Modern CLI tool integration (bat, eza, fd, ripgrep, zoxide)

**Performance features**:

- Lazy loading for mise and fzf
- Conditional module loading with DOTFILES_SKIP_* variables
- Optimized PATH management
- Performance monitoring with `shell-bench`

**Customization**:

- `config/zsh/personal-aliases` - Your shortcuts
- `config/zsh/personal-functions` - Your utilities
- Skip modules you don't need with environment variables

### Git Workflow Enhancement

**Smart commit workflow**:

- Context-aware commit message suggestions
- Interactive numbered selection or custom messages
- Suggestions based on file changes (docs, tests, config, etc.)

**Branch management**:

- `gnew feature-name` - Create and switch to branch
- `gswitch main` - Switch branches (shows all if no name)
- `gclean` - Interactive cleanup of merged branches

**Aliases**:

- `gsave` - Add, commit with suggestions, push
- `gpull` - Pull with rebase
- Traditional git aliases (g, ga, gc, gd, etc.)

### Development Automation

**Universal commands**:

- `dev` - Start development server for any project type
- `test` - Run tests for any project type
- `testwatch` - Continuous testing with file watching

**Environment detection**:

- Auto-activate .nvmrc/.python-version files with mise
- Load .env files automatically
- Trigger with `envup` or automatic on directory change

**Other tools**:

- Modern CLI alternatives with fallbacks
- Git workflow enhancement with smart commits
- tmux and Neovim configurations

## Getting Started

### 1. **Understand Before Installing**

```bash
# Review the structure
ls -la config/
cat config/git/gitconfig.template
cat install/setup.sh
```

### 2. **Install with Awareness**

```bash
# See what will happen
make install-dry-run

# Install with control
make install
```

### 3. **Customize Immediately**

- Review and edit `config.json` with your personal info
- Add aliases to `config/zsh/personal-aliases`
- Create functions in `config/zsh/personal-functions`
- Customize prompt in `config/zsh/prompt` or skip with DOTFILES_SKIP_PROMPT=1

## Customization Philosophy

### **Don't Just Copy—Understand**

```bash
# Bad: Blindly copying someone's aliases
alias gp="git push"
alias gc="git commit"

# Good: Understanding and adapting to your workflow
alias gps="git push --set-upstream origin \$(git branch --show-current)"
alias gcm="git commit -m"  # You prefer inline messages
alias gca="git commit --amend"  # You frequently amend
```

### **Build Your Development Identity**

Your dotfiles should answer these questions:

- What languages/frameworks do you work with?
- What's your preferred workflow (terminal vs GUI, vim vs other editors)?
- How do you organize projects and navigate code?
- What repetitive tasks can you automate?

### **Current Git Workflow Enhancement**

**Smart commit suggestions work like this**:

```bash
# When you run gsave, you get context-aware suggestions
gsave
# Suggestions:
# 1. 📚 Update documentation
# 2. feat: add new feature
# 3. fix: resolve bug
# 4. Update performance.md
# Commit message (or number): 1

# Creates commit: "📚 Update documentation"
```

**Branch management**:

```bash
gnew feature/auth     # Create and switch to branch
gswitch              # Shows all branches to choose from
gclean               # Interactively remove merged branches
```

### **Personal Adaptation Examples**

**Frontend Developer**:

```bash
# Add to config/zsh/personal-aliases
alias dev="npm run dev"
alias build="npm run build"
alias test="npm test"

# Add to config/zsh/personal-functions
npm_fresh() {
    rm -rf node_modules package-lock.json
    npm install
}
```

**Backend Developer**:

```bash
# Docker-focused in personal-aliases
alias dc="docker-compose"
alias dcu="docker-compose up -d"
alias logs="docker-compose logs -f"

# Add to personal-functions
db_reset() {
    docker-compose down
    docker-compose up -d postgres
    npm run migrate
}
```

## Advanced Customization

### **Performance Customization**

```bash
# Skip features you don't need
export DOTFILES_SKIP_PROMPT=1        # Use your own prompt
export DOTFILES_SKIP_CROSS_PLATFORM=1  # Skip platform detection
export DOTFILES_SKIP_PERFORMANCE=1    # Skip performance tools

# Measure your changes
shell-bench 5    # Benchmark startup time
```

### **Git Workflow Customization**

```bash
# Extend git-helpers for your workflow
# Add to config/zsh/personal-functions
deploy() {
    gsave && git push origin main
    echo "Deployed to production"
}

feature() {
    gnew "feature/$1"
    echo "Created feature branch: feature/$1"
}
```

### **Environment-Specific Setup**

```bash
# Add to config/zsh/personal-aliases for work
if [[ "$HOST" == "work-laptop" ]]; then
    alias vpn="sudo openconnect work-vpn.company.com"
    alias k="kubectl --context=work"
fi

# Personal laptop
if [[ "$HOST" == "personal-mbp" ]]; then
    alias blog="cd ~/projects/blog && code ."
fi
```

## Quality & Testing

### **Current Quality Measures**

- **Performance**: Fast shell startup with lazy loading
- **Testing**: 20+ pre-commit validation checks
- **Security**: Secret scanning, SSH validation, private key detection
- **Cross-Platform**: Tested on macOS, Linux, WSL

### **Test Your Customizations**

```bash
make test           # Full test suite
make lint           # Shellcheck validation
shell-bench         # Performance impact
```

## Contributing Your Improvements

While this is designed for personal use, improvements to the core system are welcome:

- **Bug fixes**: Always appreciated
- **Cross-platform compatibility**: Especially Windows/WSL
- **Template enhancements**: Better separation of personal/shared config
- **Workflow tools**: General-purpose development automation

## Going Further

### **Advanced Topics**

- Setting up development containers with your dotfiles
- Automating dotfile deployment across multiple machines
- Integrating with team development standards
- Building custom completion systems

### **Resources for Inspiration**

- Study other developers' dotfiles for ideas
- Join dotfiles communities for sharing techniques
- Read documentation for tools you use daily
- Experiment with new tools and integration patterns

---

**Remember**: The best dotfiles are the ones you understand completely and have adapted to your specific needs. Use this project as a foundation, not a destination.
