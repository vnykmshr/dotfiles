# Troubleshooting

Common issues and solutions.

## Installation Issues

### Files already exist

**Problem:** Install warns `File exists: ~/.zshrc. Use --force to overwrite.`
and skips that file

**Solution:** Use force mode (moves the existing file to a backup first)

```bash
make install-force
```

Backups are saved to `~/.dotfiles-backup-{timestamp}/`; `make restore` puts
them back.

### Install stops after creating config.json

**Problem:** First `make install` prints `Created config.json from example
template` and exits

**Solution:** Edit `config.json` with your details, then run it again

```bash
make install
```

### jq is required

**Problem:** Install exits with `jq is required to read config.json`

**Solution:** `make packages`, or install jq with your package manager

## Shell Issues

### Slow shell startup

**Problem:** Shell takes >1s to start

**Diagnosis:**

```bash
# Benchmark startup time
./bin/shell-bench

# Profile zsh startup (zprof report)
DOTFILES_DEBUG=true zsh -i -c exit
```

**Solutions:**

- Skip the Linux/WSL shims: `export DOTFILES_SKIP_CROSS_PLATFORM=1` in `~/.exports.local`

### Command not found after install

**Problem:** Commands like `eza`, `bat` not found

**Solution:** Install the CLI tools

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
git config --get pager.diff  # Should show the delta path
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
brew install mise              # macOS
curl -fsS https://mise.run | sh  # Linux
```

## Platform-Specific

### Linux: zsh not default shell

**Problem:** bash still loads instead of zsh

**Solution:** `make packages` sets it, or by hand:

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
make uninstall   # remove the links
make restore     # pick a backup; files go back to their original paths
```

If install replaced nothing, there is no backup and `make restore` reports
"No backups found".

### Reset to clean state

**Problem:** Something's broken, need fresh start

**Solution:**

```bash
# Back up existing files and reinstall
make install-force

# Or remove the links and start over
make uninstall
make install
```

## Getting Help

If issues persist:

1. **Run tests:** `make test` to verify setup
2. **Dry run:** `make install-dry-run` to see what would change
3. **Open an issue:** Include OS, shell version, error messages
