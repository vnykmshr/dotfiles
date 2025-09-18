# Customization Guide

> Quick reference for adapting dotfiles to your workflow

## Common Customization Patterns

### Personal Aliases (`config/zsh/personal-aliases`)

**Development Workflow**:
```bash
# Language-specific shortcuts
alias py="python3"
alias node="node --trace-warnings"
alias go_test="go test -v ./..."

# Project navigation
alias projects="cd ~/projects"
alias work="cd ~/work"
alias dotfiles="cd ~/.dotfiles"

# Git workflow (adapt to your style)
alias gps="git push --set-upstream origin \$(git branch --show-current)"
alias gpr="gh pr create --web"  # If you use GitHub CLI
alias cleanup="git branch --merged | grep -v main | xargs -n 1 git branch -d"
```

**Environment-Specific**:
```bash
# Docker development
alias dc="docker-compose"
alias dps="docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'"
alias dclean="docker system prune -f"

# Kubernetes
alias k="kubectl"
alias kdebug="kubectl run debug --image=busybox --rm -it --restart=Never -- sh"

# Cloud platforms
alias awsprofile='export AWS_PROFILE=$(aws configure list-profiles | fzf)'
```

### Git Configuration (`config/git/gitconfig.template`)

**Personal Section** (updated during installation):
```ini
[user]
    name = Your Name
    email = your.email@domain.com
    signingkey = YOUR_GPG_KEY_ID

[core]
    editor = nvim  # or code, vim, emacs
    autocrlf = input  # adjust for Windows: true
```

**Workflow Customization**:
```ini
[alias]
    # Add your preferred aliases
    sync = !git fetch origin && git rebase origin/main
    snapshot = !git stash push -m "snapshot: $(date)" && echo "Snapshot saved"
    unstage = reset HEAD --

    # Team-specific workflows
    review = !gh pr view --web
    deploy = push origin main

[branch]
    autosetupmerge = always
    autosetuprebase = always
```

### SSH Configuration (`config/ssh/config.template`)

**Multiple Identity Management**:
```ssh
# Work identity
Host work-*
    User your-work-username
    IdentityFile ~/.ssh/work_rsa
    IdentitiesOnly yes

# Personal projects
Host github.com-personal
    HostName github.com
    User git
    IdentityFile ~/.ssh/personal_rsa

# Server shortcuts
Host prod
    HostName your-production-server.com
    User deploy
    Port 22222

Host staging
    HostName staging-server.com
    User deploy
    ProxyJump bastion-host
```

### Shell Functions (`config/zsh/functions`)

**Project Management**:
```bash
# Quick project initialization
mkproject() {
    local name="$1"
    mkdir -p ~/projects/"$name"
    cd ~/projects/"$name"
    git init
    echo "# $name" > README.md
    echo "node_modules/\n.DS_Store\n*.log" > .gitignore
}

# Environment switcher
setenv() {
    case "$1" in
        "prod") export APP_ENV=production DATABASE_URL="$PROD_DB" ;;
        "dev") export APP_ENV=development DATABASE_URL="$DEV_DB" ;;
        "test") export APP_ENV=test DATABASE_URL="$TEST_DB" ;;
        *) echo "Usage: setenv [prod|dev|test]" ;;
    esac
}
```

**Utility Functions**:
```bash
# Extract any archive
extract() {
    if [[ -f "$1" ]]; then
        case "$1" in
            *.tar.bz2) tar xjf "$1" ;;
            *.tar.gz) tar xzf "$1" ;;
            *.zip) unzip "$1" ;;
            *.rar) unrar x "$1" ;;
            *) echo "Unknown archive format" ;;
        esac
    fi
}

# Find and kill process
fkill() {
    local pid
    pid=$(ps -ef | sed 1d | fzf -m | awk '{print $2}')
    [[ -n "$pid" ]] && echo "$pid" | xargs kill -9
}
```

## Workflow Tools (`config/workflow/`)

### Custom Tool Example

Create `config/workflow/deploy-helper`:
```bash
#!/usr/bin/env bash

set -euo pipefail

deploy_to_staging() {
    echo "🚀 Deploying to staging..."
    git push origin develop
    # Add your deployment commands
    curl -X POST "$STAGING_WEBHOOK_URL"
    echo "✅ Deployed to staging"
}

deploy_to_prod() {
    echo "🚀 Deploying to production..."
    git push origin main
    # Add your deployment commands
    curl -X POST "$PROD_WEBHOOK_URL"
    echo "✅ Deployed to production"
}

rollback() {
    echo "⏪ Rolling back..."
    # Add rollback logic
    curl -X POST "$ROLLBACK_WEBHOOK_URL"
    echo "✅ Rollback complete"
}

case "${1:-}" in
    "staging") deploy_to_staging ;;
    "prod") deploy_to_prod ;;
    "rollback") rollback ;;
    *) echo "Usage: deploy-helper [staging|prod|rollback]" ;;
esac
```

Make it executable:
```bash
chmod +x config/workflow/deploy-helper
```

### Environment-Aware Tools

Create `config/workflow/project-setup`:
```bash
#!/usr/bin/env bash

detect_project_type() {
    [[ -f "package.json" ]] && echo "nodejs"
    [[ -f "Cargo.toml" ]] && echo "rust"
    [[ -f "requirements.txt" ]] && echo "python"
    [[ -f "go.mod" ]] && echo "golang"
    [[ -f "pom.xml" ]] && echo "maven"
}

setup_nodejs() {
    npm install
    [[ -f ".nvmrc" ]] && nvm use
    echo "Node.js project ready"
}

setup_python() {
    python -m venv venv
    source venv/bin/activate
    pip install -r requirements.txt
    echo "Python project ready"
}

# Main setup logic
main() {
    local project_type
    project_type=$(detect_project_type)

    case "$project_type" in
        "nodejs") setup_nodejs ;;
        "python") setup_python ;;
        *) echo "Unknown project type" ;;
    esac
}

main "$@"
```

## Editor Integration

### Neovim Configuration (`config/nvim/init.lua`)

**Language-Specific Setup**:
```lua
-- Customize for your primary languages
local lsp_servers = {
    'typescript-language-server',  -- Your main language
    'rust-analyzer',               -- If you use Rust
    'python-lsp-server',           -- If you use Python
}

-- Key mappings for your workflow
vim.keymap.set('n', '<leader>ff', ':Telescope find_files<CR>')
vim.keymap.set('n', '<leader>fg', ':Telescope live_grep<CR>')
vim.keymap.set('n', '<leader>gt', ':LazyGit<CR>')  -- If you use LazyGit
```

## Testing Your Customizations

Always test changes:
```bash
# Test syntax
make lint

# Test functionality
make test

# Test in isolation
DRY_RUN=true ./install/setup.sh
```

## Environment Variables

Add to `config/zsh/zshrc` or create `~/.zshrc.local`:
```bash
# Development tools
export EDITOR="nvim"
export BROWSER="firefox"
export TERM="xterm-256color"

# Language-specific
export NODE_ENV="development"
export PYTHONPATH="$HOME/projects/python-libs"
export GOPATH="$HOME/go"

# Personal workflow
export PROJECTS_DIR="$HOME/projects"
export WORK_DIR="$HOME/work"
export NOTES_DIR="$HOME/notes"
```

## Integration with External Tools

### GitHub CLI Configuration
```bash
# Add to personal-aliases
alias pr="gh pr create --web"
alias issues="gh issue list"
alias clone="gh repo clone"
```

### Docker Development
```bash
# Add to functions
dexec() {
    local container="$1"
    shift
    docker exec -it "$container" "${@:-bash}"
}

dlogs() {
    docker logs -f "${1:-$(docker ps -q | head -1)}"
}
```

## Maintenance

### Regular Updates
```bash
# Keep your setup current
cd ~/.dotfiles
git pull origin main
make test  # Ensure everything still works
```

### Backup Important Customizations
```bash
# Keep track of your changes
git add config/zsh/personal-aliases
git add config/git/gitconfig.template
git commit -m "Personal customizations update"
```

### Share Improvements
Consider contributing useful patterns back to the main project or sharing with your team.

---

**Pro Tip**: Start small with a few key aliases and functions, then gradually build your customizations as you identify repetitive tasks in your workflow.