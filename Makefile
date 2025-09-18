# Dotfiles automation

SHELL := /bin/bash
.DEFAULT_GOAL := help

# Colors for output
define blue
	@printf "\033[0;34m$(1)\033[0m\n"
endef

.PHONY: help install test validate clean tools

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

validate: ## Validate structure
	$(call blue,"Validating structure...")
	@test -f install/setup.sh || (echo "❌ Missing setup.sh" && exit 1)
	@test -f config/zsh/zshrc || (echo "❌ Missing zshrc" && exit 1)
	@test -f config/git/gitconfig.template || (echo "❌ Missing gitconfig template" && exit 1)
	@echo "✅ Validation passed"

lint: ## Lint shell scripts
	$(call blue,"Linting scripts...")
	@./tests/lint.sh

quality: validate lint test ## Run all quality checks

status: ## Show status
	@echo "📁 $(shell pwd)"
	@echo "🔀 $(shell git branch --show-current 2>/dev/null || echo 'not a git repo')"
	@echo "📊 $(shell find . -name '*.sh' | wc -l | tr -d ' ') shell scripts"
	@echo "⚙️  $(shell find config -type f | wc -l | tr -d ' ') config files"

tools: ## Show development tools status
	$(call blue,"Development Tools Status")
	@echo "Core tools:"
	@printf "  %-12s %s\n" "pre-commit:" "$$(command -v pre-commit >/dev/null && echo '✅ installed' || echo '❌ not found')"
	@printf "  %-12s %s\n" "mise:" "$$(command -v mise >/dev/null && echo '✅ installed' || echo '❌ not found')"
	@printf "  %-12s %s\n" "shellcheck:" "$$(command -v shellcheck >/dev/null && echo '✅ installed' || echo '❌ not found')"
	@printf "  %-12s %s\n" "shfmt:" "$$(command -v shfmt >/dev/null && echo '✅ installed' || echo '❌ not found')"
	@echo "Modern CLI tools:"
	@printf "  %-12s %s\n" "ripgrep:" "$$(command -v rg >/dev/null && echo '✅ installed' || echo '❌ not found')"
	@printf "  %-12s %s\n" "fd:" "$$(command -v fd >/dev/null && echo '✅ installed' || echo '❌ not found')"
	@printf "  %-12s %s\n" "bat:" "$$(command -v bat >/dev/null && echo '✅ installed' || echo '❌ not found')"
	@printf "  %-12s %s\n" "eza:" "$$(command -v eza >/dev/null && echo '✅ installed' || echo '❌ not found')"
	@printf "  %-12s %s\n" "delta:" "$$(command -v delta >/dev/null && echo '✅ installed' || echo '❌ not found')"
	@printf "  %-12s %s\n" "zoxide:" "$$(command -v zoxide >/dev/null && echo '✅ installed' || echo '❌ not found')"

clean: ## Clean temporary files
	@find . -name "*.backup.*" -delete 2>/dev/null || true
	@find . -name ".DS_Store" -delete 2>/dev/null || true
	@echo "🧹 Cleaned temporary files"

dev: ## Setup development environment (pre-commit, hooks, linting)
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
