# Dotfiles automation

SHELL := /bin/bash
.DEFAULT_GOAL := help

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

install: ## Install dotfiles
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
	@echo "🧹 Cleaned temporary files"

dev: ## Install pre-commit hooks
	@command -v pre-commit >/dev/null || { echo "pre-commit not found: brew install pre-commit, or pipx install pre-commit"; exit 1; }
	@pre-commit install

packages: ## Install system packages
	@DOTFILES_DIR=$(PWD) source install/install-packages && install_packages_main

update: ## Update from git
	@git pull origin main

sync: update install ## Update and install

restore: ## Restore from backup
	@echo "Available backups:"
	@ls -1td ~/.dotfiles-backup-* 2>/dev/null | head -5 | nl || echo "No backups found"
	@echo
	@read -p "Enter backup number to restore (or path): " backup; \
	if [[ $$backup =~ ^[0-9]+$$ ]]; then \
		backup_path=$$(ls -1td ~/.dotfiles-backup-* 2>/dev/null | sed -n "$${backup}p"); \
	else \
		backup_path=$$backup; \
	fi; \
	if [[ ! -d "$$backup_path" ]]; then \
		echo "❌ Backup not found: $$backup_path"; \
		exit 1; \
	fi; \
	echo "Restoring from: $$backup_path"; \
	cp -rv "$$backup_path"/.??* ~/ 2>/dev/null || true; \
	echo "✅ Restore complete"

# Must match setup_symlinks in install/setup.sh
INSTALL_LINKS := .zshrc .zshenv .gitconfig .gitignore_global .ssh/config .config/nvim .tmux.conf
# Created by earlier versions
LEGACY_LINKS := .aliases .config/mise/config.toml

uninstall: ## Uninstall dotfiles
	@echo "⚠️  This will remove installed dotfiles"
	@echo "Backups in ~/.dotfiles-backup-* will be preserved"
	@read -p "Continue? (y/N) " confirm && [[ $$confirm == [yY] ]] || exit 1
	@for link in $(INSTALL_LINKS) $(LEGACY_LINKS) .dotfiles; do \
		if [[ -L ~/$$link ]]; then \
			echo "Removing symlink: ~/$$link"; \
			rm -f ~/$$link; \
		fi; \
	done
	@echo "✅ Uninstall complete. Run 'make restore' to restore from backup"
