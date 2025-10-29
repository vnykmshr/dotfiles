# Troubleshooting

Common issues and solutions.

## Installation Issues

### Permission denied errors

**Problem:** `permission denied` when running setup

**Solution:**

```bash
chmod +x install/setup.sh
./install/setup.sh
```

### Files already exist

**Problem:** Installation fails because config files exist

**Solution:** Use force mode (creates backup first)

```bash
make install-force
```

Backups are saved to `~/.dotfiles-backup-{timestamp}/`

### Template placeholders remain

**Problem:** Configs contain `{{ user.name }}` after installation

**Solution:** Create `config.json` from template

```bash
cp config.json.example config.json
# Edit config.json with your details
make install
```

## Shell Issues

### Slow shell startup

**Problem:** Shell takes >1s to start

**Diagnosis:**

```bash
# Benchmark startup time
./bin/shell-bench

# Profile zsh startup
zsh -xv 2>&1 | ts -i '%.s'
```

**Solutions:**

- Disable unused modules: `export DOTFILES_SKIP_WORKFLOW=1`
- Check for network-dependent operations
- Review `.zshrc` for heavy operations

### Command not found after install

**Problem:** Commands like `eza`, `bat` not found

**Solution:** Install modern CLI tools

```bash
make packages
```

### Completions not working

**Problem:** Tab completion fails or shows warnings

**Solution:** Rebuild completion cache

```bash
rm -f ~/.zcompdump*
exec zsh
```

## Git Issues

### Git config not applied

**Problem:** Git configuration not working

**Solution:** Verify config was generated from template

```bash
# Check if config exists
cat config/git/gitconfig | head -5

# If it shows {{ placeholders }}, regenerate
make install
```

### Delta not showing colors

**Problem:** Git diff not using delta

**Solution:** Ensure delta is installed and configured

```bash
which delta
git config --get core.pager  # Should show 'delta'
```

## Tool-Specific Issues

### tmux: command not found

**Problem:** tmux not available

**Solution:**

```bash
# macOS
brew install tmux

# Ubuntu/Debian
sudo apt install tmux
```

### nvim errors on startup

**Problem:** Neovim shows errors when opening

**Solution:** Update plugin manager

```bash
nvim --headless "+Lazy! sync" +qa
```

### mise not found

**Problem:** Language runtime manager not available

**Solution:**

```bash
curl https://mise.run | sh
```

## Platform-Specific

### macOS: Operation not permitted

**Problem:** Can't write to `/usr/local`

**Solution:** Use Homebrew's recommended directory

```bash
# Apple Silicon (M1/M2)
# Homebrew installs to /opt/homebrew

# Intel
# Homebrew installs to /usr/local
```

### Linux: zsh not default shell

**Problem:** bash still loads instead of zsh

**Solution:**

```bash
chsh -s $(which zsh)
# Logout and login again
```

### WSL: Slow file operations

**Problem:** Shell slow on Windows Subsystem for Linux

**Solution:** Keep dotfiles in Linux filesystem

```bash
# Move to ~/ instead of /mnt/c/
cd ~
git clone https://github.com/vnykmshr/dotfiles.git .dotfiles
```

## Recovery

### Restore from backup

**Problem:** Need to undo dotfiles installation

**Solution:**

```bash
# List backups
ls -la ~ | grep dotfiles-backup

# Manually restore (replace {timestamp})
cp -r ~/.dotfiles-backup-{timestamp}/.zshrc ~/.zshrc
# Repeat for other files
```

### Reset to clean state

**Problem:** Something's broken, need fresh start

**Solution:**

```bash
# Backup and reinstall everything
make reset

# Or manual cleanup
rm -rf ~/.dotfiles
rm ~/.zshrc ~/.gitconfig ~/.tmux.conf
# Then reinstall
```

## Getting Help

If issues persist:

1. **Check logs:** Installation creates logs in `/tmp/`
2. **Run tests:** `make test` to verify setup
3. **Dry run:** `make install-dry-run` to see what would change
4. **Open an issue:** Include OS, shell version, error messages
