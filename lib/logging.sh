#!/usr/bin/env bash

# Logging utilities for dotfiles scripts

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { printf "${BLUE}i %s${NC}\n" "$*" >&2; }
log_success() { printf "${GREEN}ok %s${NC}\n" "$*" >&2; }
log_warn() { printf "${YELLOW}! %s${NC}\n" "$*" >&2; }
log_error() { printf "${RED}x %s${NC}\n" "$*" >&2; }
log_step() { printf "\n${BLUE}-- %s${NC}\n" "$*" >&2; }
