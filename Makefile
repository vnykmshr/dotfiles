# Dotfiles automation

SHELL := /bin/bash
.DEFAULT_GOAL := help

# Physical repo path, wherever make runs from (make -f, make -C)
REPO := $(patsubst %/,%,$(dir $(realpath $(lastword $(MAKEFILE_LIST)))))

# Colors for output
define blue
	@printf "\033[0;34m$(1)\033[0m\n"
endef

.PHONY: help install test clean

help: ## Show this help
	@echo "Dotfiles Management Commands"
	@echo "============================"
	@echo
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[0;34m%-20s\033[0m %s\n", $$1, $$2}'

install: ## Link configs and generate personal ones
	@./install/setup.sh

install-dry-run: ## Preview installation
	@DRY_RUN=true ./install/setup.sh

install-force: ## Force install (overwrite existing)
	@FORCE=true ./install/setup.sh

test: ## Run all tests
	$(call blue,"Running tests...")
	@./tests/test-all.sh

lint: ## Run pre-commit hooks on all files
	@command -v pre-commit >/dev/null || { echo "pre-commit not found: brew install pre-commit, or pipx install pre-commit"; exit 1; }
	@pre-commit run --all-files

quality: lint test ## Run all quality checks

clean: ## Clean temporary files
	@find . -name "*.backup.*" -delete 2>/dev/null || true
	@find . -name ".DS_Store" -delete 2>/dev/null || true
	@echo "Cleaned temporary files"

dev: ## Install pre-commit hooks
	@command -v pre-commit >/dev/null || { echo "pre-commit not found: brew install pre-commit, or pipx install pre-commit"; exit 1; }
	@pre-commit install

packages: ## Install prerequisites and packages, set zsh as login shell
	@./install/setup.sh --packages

macos-defaults: ## Apply macOS system defaults (install/defaults/macos)
	@./install/defaults/macos

update: ## Update from git
	@git pull origin main

sync: update install ## Update and install

restore: ## Restore files an install replaced, from ~/.dotfiles-backup-*
	@set -e; source "$(REPO)/lib/utils.sh"; repo="$(REPO)"; \
	backups=$$(ls -1td ~/.dotfiles-backup-* 2>/dev/null | head -5); \
	if [[ -z "$$backups" ]]; then \
		echo "No backups found in ~/.dotfiles-backup-*" >&2; \
		exit 1; \
	fi; \
	echo "Available backups:"; \
	echo "$$backups" | nl; \
	echo; \
	read -p "Enter backup number to restore (or path): " backup; \
	if [[ $$backup =~ ^[0-9]+$$ ]]; then \
		backup_path=$$(echo "$$backups" | sed -n "$${backup}p"); \
	else \
		backup_path=$$backup; \
	fi; \
	if [[ -z "$$backup_path" || ! -d "$$backup_path" ]]; then \
		echo "Backup not found: $${backup_path:-$$backup}" >&2; \
		exit 1; \
	fi; \
	echo "Restoring from: $$backup_path"; \
	restored=0; managed=" "; \
	for link in $(INSTALL_LINKS) $(LEGACY_LINKS) .dotfiles; do \
		managed+="$${link%%/*} "; \
		[[ -e "$$backup_path/$$link" || -L "$$backup_path/$$link" ]] || continue; \
		if [[ -e ~/$$link || -L ~/$$link ]] && ! removable_link ~/$$link "$$repo"; then \
			echo "Skipping ~/$$link: exists and is not a link into this repo" >&2; \
			continue; \
		fi; \
		if removable_link ~/$$link "$$repo"; then \
			rm -f ~/$$link; \
		fi; \
		if [[ $$link == .ssh/* ]]; then \
			mkdir -p -m 700 "$$(dirname ~/$$link)"; \
		else \
			mkdir -p "$$(dirname ~/$$link)"; \
		fi; \
		cp -Rp "$$backup_path/$$link" ~/$$link; \
		echo "Restored ~/$$link"; \
		restored=$$((restored + 1)); \
	done; \
	for entry in "$$backup_path"/* "$$backup_path"/.[!.]*; do \
		[[ -e "$$entry" || -L "$$entry" ]] || continue; \
		[[ $$managed == *" $$(basename "$$entry") "* ]] || \
			echo "Skipped $$entry: not a path install manages; restore it by hand" >&2; \
	done; \
	if [[ $$restored -eq 0 ]]; then \
		echo "Nothing restored from $$backup_path" >&2; \
		exit 1; \
	fi; \
	echo "Restore complete"

# Must match setup_symlinks in install/setup.sh
INSTALL_LINKS := .zshrc .zshenv .gitconfig .gitignore_global .ssh/config .config/nvim .tmux.conf
# Created by earlier versions
LEGACY_LINKS := .aliases .config/mise/config.toml

uninstall: ## Remove the links (keeps backups)
	@echo "This removes the links install created"
	@echo "Backups in ~/.dotfiles-backup-* will be preserved"
	@read -p "Continue? (y/N) " confirm && [[ $$confirm == [yY] ]] || exit 1
	@set -e; source "$(REPO)/lib/utils.sh"; repo="$(REPO)"; \
	for link in $(INSTALL_LINKS) $(LEGACY_LINKS) .dotfiles; do \
		if removable_link ~/$$link "$$repo"; then \
			echo "Removing symlink: ~/$$link"; \
			rm -f ~/$$link; \
		elif [[ -L ~/$$link ]]; then \
			echo "Skipping ~/$$link: points outside this repo"; \
		fi; \
	done
	@echo "Uninstall complete. Run 'make restore' to put back files install replaced"
