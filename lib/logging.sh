#!/usr/bin/env bash

# Logging utilities for dotfiles setup

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m' # Used in some contexts
CYAN='\033[0;36m'
WHITE='\033[1;37m' # Reserved for future use
GRAY='\033[0;90m'
NC='\033[0m' # No Color

# Log levels
LOG_LEVEL="${LOG_LEVEL:-INFO}"

# Icons/symbols
CHECKMARK="✓"
CROSS="✗"
# ARROW="→" # Unused - can be removed
WARNING="⚠"
INFO="ℹ"
GEAR="⚙"

# Get timestamp
timestamp() {
    date '+%Y-%m-%d %H:%M:%S'
}

# Check if we should log at given level
should_log() {
    local level="$1"
    case "$LOG_LEVEL" in
        DEBUG) [[ $level =~ ^(DEBUG|INFO|WARN|ERROR)$ ]] ;;
        INFO) [[ $level =~ ^(INFO|WARN|ERROR)$ ]] ;;
        WARN) [[ $level =~ ^(WARN|ERROR)$ ]] ;;
        ERROR) [[ $level == "ERROR" ]] ;;
        *) true ;;
    esac
}

# Generic log function
log() {
    local level="$1"
    local color="$2"
    local icon="$3"
    shift 3
    local message="$*"

    if should_log "$level"; then
        if [[ -t 1 ]]; then
            # Terminal output with colors
            printf "${color}${icon} %s${NC}\n" "$message" >&2
        else
            # Non-terminal output without colors
            printf "[%s] %s %s\n" "$(timestamp)" "$level" "$message" >&2
        fi
    fi
}

# Log debug message
log_debug() {
    log "DEBUG" "$GRAY" "$INFO" "$@"
}

# Log info message
log_info() {
    log "INFO" "$BLUE" "$INFO" "$@"
}

# Log success message
log_success() {
    log "INFO" "$GREEN" "$CHECKMARK" "$@"
}

# Log warning message
log_warn() {
    log "WARN" "$YELLOW" "$WARNING" "$@"
}

# Log error message
log_error() {
    log "ERROR" "$RED" "$CROSS" "$@"
}

# Log step/section header
log_step() {
    local message="$*"
    if [[ -t 1 ]]; then
        printf "\n${CYAN}${GEAR} %s${NC}\n" "$message" >&2
        printf "${GRAY}%*s${NC}\n" "${#message}" | tr ' ' '-' >&2
    else
        printf "\n[%s] STEP %s\n" "$(timestamp)" "$message" >&2
        printf "%*s\n" "${#message}" "" | tr ' ' '-' >&2
    fi
}

# Log command execution
log_cmd() {
    local cmd="$1"
    if [[ $VERBOSE == "true" ]]; then
        log_debug "Running: $cmd"
    fi
}

# Log file operation
log_file() {
    local operation="$1"
    local file="$2"
    log_info "$operation: $file"
}

# Log with custom color and icon
log_custom() {
    local color="$1"
    local icon="$2"
    shift 2
    local message="$*"

    if [[ -t 1 ]]; then
        printf "${color}${icon} %s${NC}\n" "$message" >&2
    else
        printf "[%s] %s\n" "$(timestamp)" "$message" >&2
    fi
}

# Show a spinner while executing a command
with_spinner() {
    local cmd="$1"
    local message="${2:-Working...}"
    local pid

    if [[ $DRY_RUN == "true" ]]; then
        log_info "[DRY RUN] $message"
        log_debug "Would run: $cmd"
        return 0
    fi

    # Start the command in background
    eval "$cmd" >/dev/null 2>&1 &
    pid=$!

    # Show spinner while command runs
    local spin='-\|/'
    local i=0
    printf "%s " "$message" >&2
    while kill -0 $pid 2>/dev/null; do
        i=$(((i + 1) % 4))
        printf "\b%s" "${spin:i:1}" >&2
        sleep .1
    done

    # Wait for command to finish and get exit code
    wait $pid
    local exit_code=$?

    if [[ $exit_code -eq 0 ]]; then
        printf "\b%s%s%s\n" "$GREEN" "$CHECKMARK" "$NC" >&2
    else
        printf "\b%s%s%s\n" "$RED" "$CROSS" "$NC" >&2
    fi

    return $exit_code
}

# Create a progress bar
progress_bar() {
    local current="$1"
    local total="$2"
    local width="${3:-50}"
    local message="${4:-Progress}"

    local percentage=$((current * 100 / total))
    local filled=$((current * width / total))
    local empty=$((width - filled))

    printf "\r%s [" "$message" >&2
    printf "%*s" "$filled" "" | tr ' ' '█' >&2
    printf "%*s" "$empty" "" | tr ' ' '░' >&2
    printf "] %d%% (%d/%d)" "$percentage" "$current" "$total" >&2

    if [[ $current -eq $total ]]; then
        printf "\n" >&2
    fi
}

# Print a separator line
separator() {
    local char="${1:-=}"
    local width="${2:-80}"

    if [[ -t 1 ]]; then
        printf "${GRAY}%*s${NC}\n" "$width" "" | tr ' ' "$char" >&2
    else
        printf "%*s\n" "$width" "" | tr ' ' "$char" >&2
    fi
}
