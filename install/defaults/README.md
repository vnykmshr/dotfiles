# macOS Defaults Automation

Practical system preferences configuration for developer productivity.

## What It Does

Configures essential macOS settings that improve development workflow:

- **Keyboard**: Fast key repeat, disable text transformations that interfere with code
- **Finder**: Show file extensions, hidden files, path bar, disable .DS_Store files
- **Dock**: Auto-hide with fast response, optimal sizing, hide recent apps
- **Security**: Prevent data loss, require password after sleep
- **Performance**: Reduce visual effects, faster animations
- **Development**: Plain text mode, organized screenshots, terminal security

## Usage

Automatically runs during setup:
```bash
./install/setup.sh
```

Run separately with dry-run:
```bash
DRY_RUN=true ./install/defaults/macos
```

Apply immediately:
```bash
./install/defaults/macos
```

## Applied Settings

### Keyboard & Input
- Key repeat rate: Maximum speed (KeyRepeat=2, InitialKeyRepeat=15)
- Disable: Auto-capitalization, smart quotes, auto-correct

### Finder Improvements
- Show all file extensions and hidden files
- Enable path bar and status bar
- Folders first in list view
- Search current folder by default
- No .DS_Store on network/USB volumes

### Dock Optimization
- Auto-hide with instant response
- 48px icon size
- Minimize to application icon
- Hide recent applications

### Security
- Disable automatic app termination
- Immediate password requirement after sleep

### Performance
- Reduce transparency effects (may require accessibility permissions)
- Faster Mission Control animations
- Always show scrollbars
- Disable Resume system-wide

### Development
- TextEdit in plain text mode
- Screenshots to ~/Screenshots in JPG format
- Terminal secure keyboard entry and UTF-8

## Reverting Changes

Most settings can be reversed:
```bash
# Re-enable setting
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool true

# Remove custom setting to restore default
defaults delete com.apple.dock autohide-delay
```

Some changes require logout/login to take full effect.