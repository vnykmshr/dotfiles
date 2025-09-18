# Customization Guide

> Quick reference for adapting dotfiles to your workflow

## Quick Start Customization

### 1. Personal Info (`config.json`)

Update with your details during installation:

```json
{
  "git": {
    "name": "Your Name",
    "email": "you@example.com",
    "editor": "code --wait"
  },
  "workspace": "~/projects"
}
```

### 2. Personal Aliases (`config/zsh/personal-aliases`)

**Git Workflow Enhancement**:

```bash
# Build on existing git workflow
alias gpsf="gsave && git push --force-with-lease"
alias sync="gpull && gsave"

# Project-specific shortcuts
alias work="cd ~/work && gswitch main"
alias personal="cd ~/personal && gswitch main"
```

**Development Shortcuts**:

```bash
# Language-specific
alias py="python3"
alias node="node --trace-warnings"

# Docker workflow
alias dc="docker-compose"
alias dcup="docker-compose up -d"
alias dcdown="docker-compose down"

# Project automation (builds on universal commands)
alias devlog="dev 2>&1 | tee dev.log"
alias testlog="test 2>&1 | tee test.log"
```

### 3. Personal Functions (`config/zsh/personal-functions`)

**Project Utilities**:

```bash
# Quick project setup
mkproject() {
    mkdir -p ~/projects/$1
    cd ~/projects/$1
    git init
    gnew main
}

# Environment management
use_node() {
    export PATH="/usr/local/opt/node@$1/bin:$PATH"
}

# Docker helpers
dcbash() {
    docker-compose exec ${1:-app} bash
}
```

## Performance Tuning

### Skip Unused Features

```bash
# Add to ~/.zshrc.local or config/zsh/exports.local
export DOTFILES_SKIP_PROMPT=1        # Use starship/oh-my-zsh instead
export DOTFILES_SKIP_CROSS_PLATFORM=1  # Skip if single platform
export DOTFILES_SKIP_PERFORMANCE=1    # Skip monitoring tools
```

### Measure Impact

```bash
shell-bench 5           # Benchmark startup time
make test               # Validate your changes
```

## Git Workflow Customization

### Extend Smart Commits

```bash
# Add to personal-functions
quick_fix() {
    gsave && git push && echo "Quick fix deployed!"
}

feature_done() {
    gsave "feat: complete $1 implementation"
    gswitch main
    gclean
}
## Environment-Specific Customization

### Work vs Personal Setup

```bash
# Add to config/zsh/exports.local (created during install)
if [[ "$HOST" == "work-laptop" ]]; then
    export WORK_MODE=1
    alias k="kubectl --context=work"
    alias vpn="sudo openconnect work-vpn.company.com"
fi

# Personal laptop
if [[ "$HOST" == "personal-mbp" ]]; then
    alias blog="cd ~/projects/blog"
    alias side="cd ~/projects/side-projects"
fi
```

### Team Workflow Integration

```bash
# Add to personal-functions for team conventions
deploy() {
    local env="${1:-staging}"
    gsave "deploy: $env release $(date +%Y%m%d)"
    git push origin main
    echo "Deployed to $env"
}

standup() {
    echo "Yesterday: $(git log --oneline --since='1 day ago' --author='$(git config user.name)')"
    echo "Today: Working on $(git branch --show-current | sed 's/feature\///')"
}
```

## Testing Your Changes

```bash
# Validate configuration
make test

# Check performance impact
shell-bench 3

# Lint shell scripts
make lint
```

## Common Patterns

### Frontend Developer

```bash
# package.json script shortcuts (universal commands handle dev/test)
alias build="npm run build"
alias lint="npm run lint"
alias preview="npm run preview"

# Node version management with existing mise integration
use_node() {
    mise use node@$1
}
```

### Backend Developer

```bash
# Database shortcuts
alias db_reset="docker-compose down && docker-compose up -d postgres"
alias db_migrate="npm run migrate"

# API testing
api_test() {
    curl -s "http://localhost:3000/$1" | jq
}
```

### DevOps Engineer

```bash
# Kubernetes shortcuts (builds on existing k alias)
alias pods="kubectl get pods"
alias logs="kubectl logs -f"

# Infrastructure
tf_plan() {
    terraform plan -var-file="envs/$1.tfvars"
}
```

Remember: Start small, test changes, and build your personal development identity gradually.
