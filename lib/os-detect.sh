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
            OS_VERSION="$(grep -oE '[0-9]+\.[0-9]+' /etc/redhat-release | head -1)"
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
