#!/usr/bin/env bash

# OS Detection utilities

# Detect operating system and set global variables
detect_os() {
    # Initialize variables
    OS_NAME=""
    OS_VERSION=""
    OS_ARCH=""
    PACKAGE_MANAGER=""

    # Detect architecture
    OS_ARCH="$(uname -m)"
    case "$OS_ARCH" in
        x86_64) OS_ARCH="amd64" ;;
        aarch64 | arm64) OS_ARCH="arm64" ;;
    esac

    # Detect OS
    if [[ $OSTYPE == "darwin"* ]]; then
        OS_NAME="macos"
        OS_VERSION="$(sw_vers -productVersion)"
        PACKAGE_MANAGER="brew"

    elif [[ $OSTYPE == "linux-gnu"* ]]; then
        # Use /etc/os-release if available
        if [[ -f /etc/os-release ]]; then
            # shellcheck source=/dev/null
            source /etc/os-release
            OS_NAME="$(echo "$ID" | tr '[:upper:]' '[:lower:]')"
            OS_VERSION="$VERSION_ID"

            # Set package manager based on distro
            case "$OS_NAME" in
                ubuntu | debian | pop)
                    PACKAGE_MANAGER="apt"
                    ;;
                fedora | centos | rhel | rocky | almalinux)
                    PACKAGE_MANAGER="dnf"
                    # Use yum on older systems
                    if ! command -v dnf >/dev/null 2>&1; then
                        PACKAGE_MANAGER="yum"
                    fi
                    ;;
                arch | manjaro)
                    PACKAGE_MANAGER="pacman"
                    ;;
                opensuse*)
                    PACKAGE_MANAGER="zypper"
                    ;;
                alpine)
                    PACKAGE_MANAGER="apk"
                    ;;
                *)
                    PACKAGE_MANAGER="unknown"
                    ;;
            esac

        # Fallback detection methods
        elif command -v lsb_release >/dev/null 2>&1; then
            OS_NAME="$(lsb_release -si | tr '[:upper:]' '[:lower:]')"
            OS_VERSION="$(lsb_release -sr)"
        elif [[ -f /etc/redhat-release ]]; then
            OS_NAME="redhat"
            OS_VERSION="$(cat /etc/redhat-release | grep -oE '[0-9]+\.[0-9]+' | head -1)"
            PACKAGE_MANAGER="yum"
        elif [[ -f /etc/debian_version ]]; then
            OS_NAME="debian"
            OS_VERSION="$(cat /etc/debian_version)"
            PACKAGE_MANAGER="apt"
        else
            OS_NAME="linux"
            OS_VERSION="unknown"
            PACKAGE_MANAGER="unknown"
        fi

    elif [[ $OSTYPE == "msys"* ]] || [[ $OSTYPE == "cygwin"* ]]; then
        OS_NAME="windows"
        OS_VERSION="$(cmd.exe /c ver 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)"
        PACKAGE_MANAGER="choco"

    else
        OS_NAME="unknown"
        OS_VERSION="unknown"
        OS_ARCH="unknown"
        PACKAGE_MANAGER="unknown"
    fi

    # Export variables for use in other scripts
    export OS_NAME OS_VERSION OS_ARCH PACKAGE_MANAGER
}

# Check if running on a specific OS
is_os() {
    local target_os="$1"
    [[ $OS_NAME == "$target_os" ]]
}

# Check if running on macOS
is_macos() {
    is_os "macos"
}

# Check if running on Linux
is_linux() {
    [[ $OS_NAME != "macos" && $OS_NAME != "windows" && $OS_NAME != "unknown" ]]
}

# Check if running on Windows (including WSL)
is_windows() {
    is_os "windows" || [[ -n ${WSL_DISTRO_NAME:-} ]]
}

# Check if running in WSL
is_wsl() {
    [[ -n ${WSL_DISTRO_NAME:-} ]] || [[ "$(uname -r)" == *microsoft* ]]
}

# Check if running on a specific Linux distribution
is_distro() {
    local target_distro="$1"
    [[ $OS_NAME == "$target_distro" ]]
}

# Get package manager install command
get_install_cmd() {
    case "$PACKAGE_MANAGER" in
        apt)
            echo "sudo apt-get install -y"
            ;;
        dnf)
            echo "sudo dnf install -y"
            ;;
        yum)
            echo "sudo yum install -y"
            ;;
        pacman)
            echo "sudo pacman -S --noconfirm --needed"
            ;;
        zypper)
            echo "sudo zypper install -y"
            ;;
        apk)
            echo "sudo apk add --no-cache"
            ;;
        brew)
            echo "brew install"
            ;;
        choco)
            echo "choco install -y"
            ;;
        *)
            echo "echo 'Unknown package manager: $PACKAGE_MANAGER'"
            ;;
    esac
}

# Get package manager update command
get_update_cmd() {
    case "$PACKAGE_MANAGER" in
        apt)
            echo "sudo apt-get update"
            ;;
        dnf)
            echo "sudo dnf check-update || true"
            ;;
        yum)
            echo "sudo yum check-update || true"
            ;;
        pacman)
            echo "sudo pacman -Sy"
            ;;
        zypper)
            echo "sudo zypper refresh"
            ;;
        apk)
            echo "sudo apk update"
            ;;
        brew)
            echo "brew update"
            ;;
        choco)
            echo "choco upgrade all -y"
            ;;
        *)
            echo "echo 'Unknown package manager: $PACKAGE_MANAGER'"
            ;;
    esac
}
