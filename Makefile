#!/usr/bin/make -f
# Dotfiles automation

SHELL := /bin/bash
.DEFAULT_GOAL := help

# Colors for output
define blue
	@printf "\033[0;34m$(1)\033[0m\n"
endef

.PHONY: help install test validate clean

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
	@./tests/test-configs.sh
	@./tests/test-install.sh

test-configs: ## Test configurations only
	@./tests/test-configs.sh

test-install: ## Test installation only
	@./tests/test-install.sh

validate: ## Validate structure
	$(call blue,"Validating structure...")
	@test -f install/setup.sh || (echo "❌ Missing setup.sh" && exit 1)
	@test -f config/zsh/zshrc || (echo "❌ Missing zshrc" && exit 1)
	@test -f config/git/gitconfig || (echo "❌ Missing gitconfig" && exit 1)
	@echo "✅ Validation passed"

lint: ## Lint shell scripts
	$(call blue,"Linting scripts...")
	@./tests/lint-scripts.sh

lint-fix: ## Auto-fix linting issues
	@./tests/lint-scripts.sh --fix

format: ## Check formatting
	@./tests/format-check.sh

format-fix: ## Auto-fix formatting
	@./tests/format-check.sh --fix

quality: validate lint format test ## Run all quality checks

status: ## Show status
	@echo "📁 $(shell pwd)"
	@echo "🔀 $(shell git branch --show-current 2>/dev/null || echo 'not a git repo')"
	@echo "📊 $(shell find . -name '*.sh' | wc -l | tr -d ' ') shell scripts"
	@echo "⚙️  $(shell find config -type f | wc -l | tr -d ' ') config files"

clean: ## Clean temporary files
	@find . -name "*.backup.*" -delete 2>/dev/null || true
	@find . -name ".DS_Store" -delete 2>/dev/null || true
	@echo "🧹 Cleaned temporary files"

dev: ## Setup development environment
	@./install/setup-pre-commit.sh

packages: ## Install system packages
	@source install/install-packages && install_packages

update: ## Update from git
	@git pull origin main

sync: update install ## Update and install

reset: ## Reset to clean state
	@echo "⚠️  This will backup and reinstall everything"
	@read -p "Continue? (y/N) " confirm && [[ $$confirm == [yY] ]] || exit 1
	@FORCE=true $(MAKE) install

# Note: Uninstall functionality not yet implemented
# To manually uninstall, remove symlinks and restore from ~/.dotfiles-backup-*