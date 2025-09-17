# Personal Dotfiles Customizations

> Customizations based on vnykmshr's actual shell usage patterns and workflow analysis

## 📊 Usage Analysis Summary

Based on analysis of your zsh history, these customizations target your most frequent commands:

- **`gst`** (558 times) - Git status
- **`lg`** (136 times) - Git log
- **`ls`** (135 times) - Directory listing
- **`make dev`** (128 times) - Development server
- **`git diff`** (113 times) - Code review
- **`git add -u`** (87 times) - Staging changes
- **`ccusage daily`** (45 times) - Usage tracking
- **`brewski`** (27 times) - Brew updates

## 🚀 Added Personalizations

### 1. **Personal Aliases** (`config/zsh/personal-aliases`)

#### Super Quick Shortcuts
```bash
ws          # cd ~/workspace (your most common directory)
gh          # cd ~/workspace/github/vnykmshr
wh          # workflow-helper (short command)
```

#### Enhanced Git Workflow (Your Most Used Commands)
```bash
gst         # git status --short --branch (enhanced version)
gau         # git add -u (you use this 87 times!)
acp         # git add -u && git commit && git push (your full workflow)
gacp        # Alternative for same workflow
gup         # git pull && git submodule update
gcl         # git clean -fd && git reset --hard
```

#### Development Shortcuts (Based on Make Usage)
```bash
md          # make dev (instead of typing it 128 times!)
mb          # make build
mc          # make check
mt          # make test
mr          # make run
ma          # make audit
```

#### Environment Switching (You Switch Often)
```bash
dev         # export NODE_ENV=development GIN_MODE=debug ENVIRONMENT=development
prod        # export NODE_ENV=production GIN_MODE=release ENVIRONMENT=production
```

#### System Monitoring (htop Usage)
```bash
cpu         # htop --sort-key PERCENT_CPU
mem         # htop --sort-key PERCENT_MEM
proc        # ps aux | grep -v grep | grep -i
```

### 2. **Personal Functions** (`config/zsh/personal-functions`)

#### Smart Project Detection
```bash
dev()       # Detects project type and runs appropriate dev server
            # - Makefile: make dev
            # - Node.js: npm run dev or node app.js
            # - Go: go run .
            # - Flutter: flutter run
```

#### Enhanced Git Workflow
```bash
qc()        # Quick commit with auto-generated messages
acp()       # Your complete workflow: add -u, commit, push
gll()       # Enhanced git log with your preferred format
```

#### Project Management
```bash
clone()     # Clone repo and auto-setup dependencies
initproject() # Quick project initialization with type detection
status()    # Enhanced status (git + project info)
```

#### ccusage Integration (You Use This 45 Times)
```bash
cd()        # Enhanced cd that auto-tracks projects with ccusage
track_project() # Automatic project tracking
```

### 3. **Workflow Automation** (`bin/workflow-helper`)

Command-line tool that automates your most common patterns:

```bash
workflow-helper commit    # Your gst → git add -u → commit workflow
workflow-helper status    # Enhanced project status
workflow-helper deploy    # make build → production deployment
workflow-helper setup     # Project dependency setup
workflow-helper sync      # git pull → setup → build
```

Short alias: `wh commit`, `wh status`, etc.

### 4. **Smart Completions** (`config/zsh/completions`)

#### Make Target Completion
- Auto-completes Makefile targets when you type `make <TAB>`
- Works with your frequent `make dev`, `make build`, etc.

#### Project-Aware Completions
- `dev <TAB>` shows context-aware completions based on project type
- `flutter run <TAB>` shows available devices
- `npm run <TAB>` shows package.json scripts

#### Workflow Helper Completion
- `workflow-helper <TAB>` shows available commands
- `wh <TAB>` same smart completion

### 5. **Performance Optimizations**

#### Enhanced History (For Your Command Repetition)
```bash
setopt HIST_REDUCE_BLANKS     # Clean up command history
setopt HIST_FIND_NO_DUPS      # No duplicates in search
```

#### Improved Key Bindings
```bash
Ctrl+P      # Search backwards in history
Ctrl+N      # Search forwards in history
Ctrl+R      # Incremental search (enhanced)
```

## 🎯 **Workflow Improvements**

### Before vs After

#### Git Workflow (Your Most Common Pattern)
**Before:**
```bash
gst
git add -u
git commit -m "message"
git push
```

**After:**
```bash
acp "message"    # One command does it all
# or
gacp "message"   # Alternative muscle memory
```

#### Development Server
**Before:**
```bash
make dev         # 128 times in your history!
```

**After:**
```bash
md              # Short alias
# or
dev             # Smart detection (works in any project type)
```

#### Project Navigation
**Before:**
```bash
cd ~/workspace/github/vnykmshr
```

**After:**
```bash
gh              # Direct shortcut
```

### New Capabilities

#### Smart Project Commands
```bash
dev             # Automatically detects project type and runs appropriate dev server
clone <repo>    # Clone and auto-setup dependencies
status          # Git + project info in one view
workflow full   # Complete check → test → build pipeline
```

#### Enhanced Productivity
```bash
wh commit       # Complete commit workflow
wh deploy       # Build and deploy
wh sync         # Pull, setup, build
```

## 📋 **Quick Reference**

### Most Important New Commands
```bash
# Ultra-frequent shortcuts
md              # make dev (your #4 most used command)
acp "msg"       # Complete git workflow (targets #1, #5, #6 commands)
gh              # Quick navigation to your projects
wh status       # Enhanced project overview

# Smart commands
dev             # Context-aware development server
ws              # Workspace navigation
prod/dev        # Environment switching
```

### Tab Completion Enhancements
- `make <TAB>` → Shows Makefile targets
- `dev <TAB>` → Project-specific options
- `wh <TAB>` → Workflow helper commands
- `flutter run <TAB>` → Available devices

## 🔧 **Customization Tips**

### Add Your Own Aliases
Edit `~/.dotfiles/config/zsh/personal-aliases` to add more shortcuts:

```bash
# Add project-specific shortcuts
alias myapp='cd ~/workspace/github/vnykmshr/my-app && dev'
alias logs='tail -f /var/log/myapp.log'
```

### Extend Functions
Edit `~/.dotfiles/config/zsh/personal-functions` to add workflow functions:

```bash
# Add deployment shortcuts
deploy_staging() {
    make build && rsync -av ./dist/ staging:/var/www/
}
```

## 🚀 **Next Steps**

1. **Test the shortcuts**: `source ~/.zshrc` and try `md` instead of `make dev`
2. **Use workflow automation**: `wh status` for project overview
3. **Try smart commands**: `dev` in any project directory
4. **Customize further**: Add your specific project paths and workflows

These personalizations should significantly speed up your daily development workflow by targeting your exact usage patterns!