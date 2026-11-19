# Dotfiles automation

SHELL := /bin/bash
.DEFAULT_GOAL := help

# Repo dir for make -C or make -f; an absolute -f path with a space is not supported
REPO := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))

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
	@"$(REPO)/install/setup.sh"

install-dry-run: ## Preview installation
	@DRY_RUN=true "$(REPO)/install/setup.sh"

install-force: ## Force install (overwrite existing)
	@FORCE=true "$(REPO)/install/setup.sh"

test: ## Run all tests
	$(call blue,"Running tests...")
	@"$(REPO)/tests/test-all.sh"

lint: ## Run pre-commit hooks on all files
	@command -v pre-commit >/dev/null || { echo "pre-commit not found: brew install pre-commit, or pipx install pre-commit"; exit 1; }
	@cd "$(REPO)" && pre-commit run --all-files

quality: lint test ## Run all quality checks

clean: ## Clean temporary files
	@find "$(REPO)" -name "*.backup.*" -delete 2>/dev/null || true
	@find "$(REPO)" -name ".DS_Store" -delete 2>/dev/null || true
	@echo "Cleaned temporary files"

dev: ## Install pre-commit hooks
	@command -v pre-commit >/dev/null || { echo "pre-commit not found: brew install pre-commit, or pipx install pre-commit"; exit 1; }
	@cd "$(REPO)" && pre-commit install

packages: ## Install prerequisites and packages, set zsh as login shell
	@"$(REPO)/install/setup.sh" --packages

macos-defaults: ## Apply macOS system defaults (install/defaults/macos)
	@"$(REPO)/install/defaults/macos"

update: ## Update from git
	@git -C "$(REPO)" pull origin main

sync: update install ## Update and install

restore: ## Restore files an install replaced, from ~/.dotfiles-backup-*
	@"$(REPO)/install/setup.sh" --restore

uninstall: ## Remove the links (keeps backups)
	@echo "This removes the links install created"
	@echo "Backups in ~/.dotfiles-backup-* will be preserved"
	@read -p "Continue? (y/N) " confirm && [[ $$confirm == [yY] ]] || exit 1
	@"$(REPO)/install/setup.sh" --uninstall
	@[[ "$$DRY_RUN" == true ]] || echo "Uninstall complete. Run 'make restore' to put back files install replaced"
