# Dotfiles Makefile
# Professional automation for dotfiles management

# Configuration
SHELL := /bin/bash
.DEFAULT_GOAL := help

# Colors
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[1;33m
BLUE := \033[0;34m
NC := \033[0m # No Color

# Directories
DOTFILES_DIR := $(shell pwd)
BACKUP_DIR := $(HOME)/.dotfiles-backup-$(shell date +%Y%m%d-%H%M%S)

# =============================================================================
# Help Target
# =============================================================================

.PHONY: help
help: ## Show this help message
	@echo "Dotfiles Management Commands"
	@echo "============================"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "$(BLUE)%-20s$(NC) %s\n", $$1, $$2}'
	@echo ""
	@echo "Environment Variables:"
	@echo "  DRY_RUN=true      Preview changes without applying them"
	@echo "  VERBOSE=true      Enable verbose output"
	@echo "  FORCE=true        Force overwrite existing files"

# =============================================================================
# Installation Targets
# =============================================================================

.PHONY: install
install: ## Install dotfiles (full setup)
	@echo "$(GREEN)Installing dotfiles...$(NC)"
	@./install/setup.sh

.PHONY: install-dry-run
install-dry-run: ## Preview installation without making changes
	@echo "$(YELLOW)Dry run installation...$(NC)"
	@DRY_RUN=true ./install/setup.sh

.PHONY: install-force
install-force: ## Force install (overwrite existing files)
	@echo "$(RED)Force installing dotfiles...$(NC)"
	@FORCE=true ./install/setup.sh

# =============================================================================
# Update and Sync Targets
# =============================================================================

.PHONY: update
update: ## Update dotfiles from remote repository
	@echo "$(BLUE)Updating from remote repository...$(NC)"
	@git pull origin $$(git branch --show-current)

.PHONY: sync
sync: update install ## Sync dotfiles (update + install)
	@echo "$(GREEN)Sync complete!$(NC)"

# =============================================================================
# Package Management
# =============================================================================

.PHONY: packages
packages: ## Install system packages
	@echo "$(BLUE)Installing packages...$(NC)"
	@./install/install-packages

.PHONY: packages-core
packages-core: ## Install only core packages
	@echo "$(BLUE)Installing core packages...$(NC)"
	@INSTALL_DEV_TOOLS=false INSTALL_FONTS=false ./install/install-packages

.PHONY: packages-dev
packages-dev: ## Install development tools
	@echo "$(BLUE)Installing development packages...$(NC)"
	@INSTALL_DEV_TOOLS=true ./install/install-packages

# =============================================================================
# Backup and Restore
# =============================================================================

.PHONY: backup
backup: ## Create backup of current configuration
	@echo "$(YELLOW)Creating backup at $(BACKUP_DIR)...$(NC)"
	@mkdir -p $(BACKUP_DIR)
	@for file in .zshrc .bashrc .vimrc .tmux.conf .gitconfig .aliases; do \
		if [ -f "$(HOME)/$$file" ]; then \
			cp "$(HOME)/$$file" "$(BACKUP_DIR)/"; \
			echo "Backed up: $$file"; \
		fi; \
	done
	@for dir in .config/nvim .config/tmux; do \
		if [ -d "$(HOME)/$$dir" ]; then \
			cp -r "$(HOME)/$$dir" "$(BACKUP_DIR)/"; \
			echo "Backed up: $$dir"; \
		fi; \
	done
	@echo "$(GREEN)Backup created at: $(BACKUP_DIR)$(NC)"

# =============================================================================
# Testing and Validation
# =============================================================================

.PHONY: test
test: ## Run all tests
	@echo "$(BLUE)Running all tests...$(NC)"
	@$(MAKE) test-configs
	@$(MAKE) test-install

.PHONY: test-configs
test-configs: ## Test configuration files
	@echo "$(BLUE)Testing configuration files...$(NC)"
	@./tests/test-configs.sh

.PHONY: test-install
test-install: ## Run installation tests
	@echo "$(BLUE)Running installation tests...$(NC)"
	@./tests/test-install.sh

.PHONY: validate
validate: ## Validate dotfiles structure
	@echo "$(BLUE)Validating dotfiles structure...$(NC)"
	@errors=0; \
	for file in install/setup.sh config/zsh/zshrc config/git/gitconfig; do \
		if [ ! -f "$$file" ]; then \
			echo "$(RED)✗ Missing: $$file$(NC)"; \
			errors=$$((errors + 1)); \
		else \
			echo "$(GREEN)✓ Found: $$file$(NC)"; \
		fi; \
	done; \
	if [ $$errors -eq 0 ]; then \
		echo "$(GREEN)✓ Validation passed$(NC)"; \
	else \
		echo "$(RED)✗ Validation failed with $$errors errors$(NC)"; \
		exit 1; \
	fi

.PHONY: lint
lint: ## Lint shell scripts
	@echo "$(BLUE)Linting shell scripts...$(NC)"
	@./tests/lint-scripts.sh

.PHONY: lint-fix
lint-fix: ## Auto-fix linting issues
	@echo "$(BLUE)Auto-fixing linting issues...$(NC)"
	@./tests/lint-scripts.sh --fix

.PHONY: format
format: ## Check code formatting
	@echo "$(BLUE)Checking code formatting...$(NC)"
	@./tests/format-check.sh

.PHONY: format-fix
format-fix: ## Auto-fix formatting issues
	@echo "$(BLUE)Auto-fixing formatting issues...$(NC)"
	@./tests/format-check.sh --fix

.PHONY: quality
quality: ## Run all quality checks
	@echo "$(BLUE)Running all quality checks...$(NC)"
	@$(MAKE) lint
	@$(MAKE) format
	@$(MAKE) validate
	@$(MAKE) test-configs

.PHONY: fix-all
fix-all: ## Auto-fix all issues
	@echo "$(BLUE)Auto-fixing all issues...$(NC)"
	@$(MAKE) lint-fix
	@$(MAKE) format-fix

# =============================================================================
# Development Targets
# =============================================================================

.PHONY: dev
dev: ## Set up development environment
	@echo "$(BLUE)Setting up development environment...$(NC)"
	@$(MAKE) packages-dev
	@$(MAKE) install

.PHONY: edit
edit: ## Open dotfiles in editor
	@if [ -n "$$EDITOR" ]; then \
		$$EDITOR .; \
	else \
		echo "$(YELLOW)EDITOR not set. Opening in vim...$(NC)"; \
		vim .; \
	fi

# =============================================================================
# Status and Information
# =============================================================================

.PHONY: status
status: ## Show dotfiles and system status
	@echo "$(BLUE)Dotfiles Status Report$(NC)"
	@echo "======================"
	@echo ""
	@echo "Git Status:"
	@git status --short --branch
	@echo ""
	@echo "Recent Commits:"
	@git log --oneline -5
	@echo ""
	@echo "System Info:"
	@echo "OS: $$(uname -s) $$(uname -r)"
	@echo "Shell: $$SHELL"
	@echo "Editor: $${EDITOR:-not set}"
	@echo ""
	@echo "Tool Status:"
	@for tool in git zsh tmux nvim; do \
		if command -v $$tool >/dev/null 2>&1; then \
			printf "  $(GREEN)✓$(NC) %-8s %s\n" "$$tool" "$$(command -v $$tool)"; \
		else \
			printf "  $(RED)✗$(NC) %-8s %s\n" "$$tool" "not found"; \
		fi; \
	done

.PHONY: doctor
doctor: ## Run system diagnostics
	@echo "$(BLUE)Running system diagnostics...$(NC)"
	@echo ""
	@echo "Checking dependencies..."
	@missing=0; \
	for tool in git curl wget; do \
		if ! command -v $$tool >/dev/null 2>&1; then \
			echo "$(RED)✗ Missing required tool: $$tool$(NC)"; \
			missing=$$((missing + 1)); \
		fi; \
	done; \
	if [ $$missing -eq 0 ]; then \
		echo "$(GREEN)✓ All required tools found$(NC)"; \
	fi
	@echo ""
	@echo "Checking permissions..."
	@if [ -w "$(HOME)" ]; then \
		echo "$(GREEN)✓ Home directory is writable$(NC)"; \
	else \
		echo "$(RED)✗ Home directory is not writable$(NC)"; \
	fi

# =============================================================================
# Cleanup Targets
# =============================================================================

.PHONY: clean
clean: ## Clean temporary files and old backups
	@echo "$(YELLOW)Cleaning up...$(NC)"
	@find $(HOME) -maxdepth 1 -name ".dotfiles-backup-*" -type d -mtime +30 -exec rm -rf {} + 2>/dev/null || true
	@rm -rf /tmp/dotfiles-* 2>/dev/null || true
	@echo "$(GREEN)✓ Cleanup complete$(NC)"

.PHONY: uninstall
uninstall: backup ## Uninstall dotfiles (creates backup first)
	@echo "$(RED)Uninstalling dotfiles...$(NC)"
	@echo "$(YELLOW)Backup created before uninstall$(NC)"
	@for file in .zshrc .vimrc .tmux.conf .gitconfig .aliases; do \
		if [ -L "$(HOME)/$$file" ] && [ "$$(readlink $(HOME)/$$file)" = "$(DOTFILES_DIR)/config"* ]; then \
			rm "$(HOME)/$$file"; \
			echo "Removed symlink: $$file"; \
		fi; \
	done
	@if [ -L "$(HOME)/.config/nvim" ] && [ "$$(readlink $(HOME)/.config/nvim)" = "$(DOTFILES_DIR)/config/nvim" ]; then \
		rm "$(HOME)/.config/nvim"; \
		echo "Removed symlink: .config/nvim"; \
	fi
	@echo "$(GREEN)✓ Uninstall complete$(NC)"

# =============================================================================
# CI/CD Targets
# =============================================================================

.PHONY: ci
ci: validate lint test ## Run CI pipeline (validate + lint + test)
	@echo "$(GREEN)✓ CI pipeline completed successfully$(NC)"

.PHONY: pre-commit-setup
pre-commit-setup: ## Setup pre-commit hooks
	@echo "$(BLUE)Setting up pre-commit hooks...$(NC)"
	@./install/setup-pre-commit.sh

.PHONY: pre-commit
pre-commit: ## Run pre-commit checks
	@echo "$(BLUE)Running pre-commit checks...$(NC)"
	@$(MAKE) quality
	@echo "$(GREEN)✓ Pre-commit checks passed$(NC)"

# =============================================================================
# Quick Actions
# =============================================================================

.PHONY: quick-setup
quick-setup: ## Quick setup for new machines
	@echo "$(BLUE)Quick setup for new machine...$(NC)"
	@$(MAKE) packages-core
	@$(MAKE) install

.PHONY: reset
reset: ## Reset to clean state (backup + clean install)
	@echo "$(YELLOW)Resetting to clean state...$(NC)"
	@$(MAKE) backup
	@$(MAKE) clean
	@$(MAKE) install

# =============================================================================
# Documentation
# =============================================================================

.PHONY: docs
docs: ## Generate documentation
	@echo "$(BLUE)Documentation available:$(NC)"
	@echo "  README.md           - Main documentation"
	@echo "  docs/FEATURES.md    - Feature documentation"
	@echo "  docs/CUSTOMIZATION.md - Customization guide"

# =============================================================================
# Platform-specific targets
# =============================================================================

.PHONY: macos
macos: ## macOS-specific setup
	@if [ "$$(uname)" = "Darwin" ]; then \
		echo "$(BLUE)Running macOS-specific setup...$(NC)"; \
		if [ -f "./install/defaults/macos" ]; then \
			./install/defaults/macos; \
		fi; \
		$(MAKE) packages; \
	else \
		echo "$(RED)This target is only for macOS$(NC)"; \
		exit 1; \
	fi

.PHONY: linux
linux: ## Linux-specific setup
	@if [ "$$(uname)" = "Linux" ]; then \
		echo "$(BLUE)Running Linux-specific setup...$(NC)"; \
		if [ -f "./install/defaults/linux" ]; then \
			./install/defaults/linux; \
		fi; \
		$(MAKE) packages; \
	else \
		echo "$(RED)This target is only for Linux$(NC)"; \
		exit 1; \
	fi