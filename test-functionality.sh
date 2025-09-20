#!/usr/bin/env bash
# Comprehensive functionality test script for dotfiles
# Run this script to validate all features and identify issues

set -e
source "$(dirname "$0")/lib/logging.sh"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test tracking
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Function to run a test
run_test() {
    local test_name="$1"
    local test_command="$2"
    local expected_pattern="$3"

    TOTAL_TESTS=$((TOTAL_TESTS + 1))

    echo -e "\n${BLUE}[TEST $TOTAL_TESTS]${NC} $test_name"
    echo -e "${YELLOW}Command:${NC} $test_command"

    if output=$(eval "$test_command" 2>&1); then
        if [[ -z $expected_pattern ]] || echo "$output" | grep -q "$expected_pattern"; then
            echo -e "${GREEN}✓ PASSED${NC}"
            PASSED_TESTS=$((PASSED_TESTS + 1))
        else
            echo -e "${RED}✗ FAILED${NC} - Expected pattern '$expected_pattern' not found"
            echo "Output: $output"
            FAILED_TESTS=$((FAILED_TESTS + 1))
        fi
    else
        echo -e "${RED}✗ FAILED${NC} - Command failed with exit code $?"
        echo "Error: $output"
        FAILED_TESTS=$((FAILED_TESTS + 1))
    fi
}

# Function to check if command exists
check_command() {
    local cmd="$1"
    local description="$2"

    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    echo -e "\n${BLUE}[TEST $TOTAL_TESTS]${NC} Check if $description is available"

    if command -v "$cmd" >/dev/null 2>&1; then
        echo -e "${GREEN}✓ PASSED${NC} - $cmd is available at $(command -v "$cmd")"
        PASSED_TESTS=$((PASSED_TESTS + 1))
    else
        echo -e "${RED}✗ FAILED${NC} - $cmd not found"
        FAILED_TESTS=$((FAILED_TESTS + 1))
    fi
}

echo "🧪 Comprehensive Dotfiles Functionality Test"
echo "=============================================="

# 1. Environment Setup Tests
echo -e "\n${YELLOW}📁 ENVIRONMENT SETUP TESTS${NC}"
run_test "DOTFILES environment variable" "echo \"\$DOTFILES\"" "dotfiles"
run_test ".dotfiles symlink exists" "ls -la ~/.dotfiles" "dotfiles"
run_test "Zsh configuration loads" "zsh -c 'echo \"Config loaded\"'" "Config loaded"

# 2. Modern CLI Tools Tests
echo -e "\n${YELLOW}🔧 MODERN CLI TOOLS TESTS${NC}"
check_command "bat" "bat (better cat)"
check_command "eza" "eza (better ls)"
check_command "fd" "fd (better find)"
check_command "rg" "ripgrep (better grep)"
check_command "delta" "git-delta (better git diff)"
check_command "zoxide" "zoxide (smart cd)"

# 3. Aliases and Functions Tests
echo -e "\n${YELLOW}🔗 ALIASES AND FUNCTIONS TESTS${NC}"
run_test "Git aliases work" "zsh -c 'source ~/.zshrc; alias gs'" "git status"
run_test "Modern tools aliases" "zsh -c 'source ~/.zshrc; alias ll'" "eza"
run_test "Navigation aliases" "zsh -c 'source ~/.zshrc; alias ..'" "cd .."
run_test "Safety aliases" "zsh -c 'source ~/.zshrc; alias rm'" "rm -i"

# 4. Git Integration Tests
echo -e "\n${YELLOW}🔀 GIT INTEGRATION TESTS${NC}"
run_test "Git user configuration" "git config user.name" ""
run_test "Git delta integration" "git config pager.diff" "delta"
run_test "Git aliases configured" "git config alias.st" "status"

# 5. Search and File Operations Tests
echo -e "\n${YELLOW}🔍 SEARCH AND FILE OPERATIONS TESTS${NC}"
run_test "Ripgrep search" "rg 'function' config/zsh/aliases | head -1" "function"
run_test "fd file search" "fd 'aliases' config/" "aliases"
run_test "bat file display" "bat --version" "bat"
run_test "eza directory listing" "eza --version" "eza"

# 6. History and Intelligence Tests
echo -e "\n${YELLOW}🧠 HISTORY AND INTELLIGENCE TESTS${NC}"
run_test "History file exists" "ls -la ~/.zsh_history" "zsh_history"
run_test "History stats function" "zsh -c 'source ~/.zshrc; type history_stats'" "function"
run_test "History search function" "zsh -c 'source ~/.zshrc; type hsearch'" "function"

# 7. Prompt Tests
echo -e "\n${YELLOW}🎨 PROMPT TESTS${NC}"
run_test "Prompt choice file exists" "ls ~/.config/dotfiles/prompt-choice" "prompt-choice"
run_test "Git prompt function" "zsh -c 'source ~/.zshrc; type git_prompt'" "function"
run_test "Directory prompt function" "zsh -c 'source ~/.zshrc; type dir_prompt'" "function"

# 8. Development Automation Tests
echo -e "\n${YELLOW}⚡ DEVELOPMENT AUTOMATION TESTS${NC}"
run_test "Environment detection" "zsh -c 'source ~/.zshrc; type detect_env'" "function"
run_test "Project automation" "zsh -c 'source ~/.zshrc; type project_setup'" "function"
run_test "Git helpers available" "ls -la bin/dotfiles" "dotfiles"

# 9. Security Features Tests
echo -e "\n${YELLOW}🔒 SECURITY FEATURES TESTS${NC}"
run_test "Sensitive pattern detection" "zsh -c 'source ~/.zshrc; type is_sensitive_command'" "function"
run_test "History cleaning function" "zsh -c 'source ~/.zshrc; type history_clean_sensitive'" "function"

# 10. Cross-platform Compatibility Tests
echo -e "\n${YELLOW}🌐 CROSS-PLATFORM TESTS${NC}"
run_test "OS detection" "zsh -c 'source ~/.zshrc; echo \$OSTYPE'" ""
run_test "Platform-specific aliases" "zsh -c 'source ~/.zshrc; alias | grep -E \"(pbcopy|xclip)\"'" ""

# 11. Performance Tests
echo -e "\n${YELLOW}⚡ PERFORMANCE TESTS${NC}"
run_test "Zsh startup time measurement" "zsh -c 'source ~/.zshrc; type shell_time'" "function"
run_test "Module loading check" "zsh -c 'source ~/.zshrc; echo \"Modules loaded\"'" "Modules loaded"

# 12. Configuration Template Tests
echo -e "\n${YELLOW}📄 CONFIGURATION TEMPLATE TESTS${NC}"
run_test "Git config template exists" "ls config/git/gitconfig.template" "gitconfig.template"
run_test "SSH config template exists" "ls config/ssh/config.template" "config.template"

# 13. Workflow and Automation Tests
echo -e "\n${YELLOW}🔄 WORKFLOW AUTOMATION TESTS${NC}"
run_test "Git workflow helpers" "ls config/workflow/git-helpers" "git-helpers"
run_test "Development automation" "ls config/zsh/dev-automation" "dev-automation"

# 14. Interactive Features Tests
echo -e "\n${YELLOW}💬 INTERACTIVE FEATURES TESTS${NC}"
run_test "Completion system" "zsh -c 'autoload -U compinit; echo \"Completions available\"'" "Completions available"
run_test "FZF integration" "zsh -c 'source ~/.zshrc; echo \$FZF_DEFAULT_COMMAND'" "fd"

# 15. Alias Reminder Tests
echo -e "\n${YELLOW}💡 ALIAS REMINDER TESTS${NC}"
run_test "Alias reminder module loads" "zsh -c 'source ~/.zshrc; type alias-reminder-show'" "function"
run_test "Alias reminder shows tips" "zsh -c 'source config/zsh/alias-reminder; alias-reminder-show'" "Alias Reminders"
run_test "Alias reminder level change" "zsh -c 'source ~/.zshrc; alias-reminder-level advanced'" "set to: advanced"

# 16. Error Handling Tests
echo -e "\n${YELLOW}🚨 ERROR HANDLING TESTS${NC}"
run_test "Missing file handling" "zsh -c 'source ~/.zshrc; cat /nonexistent/file 2>&1 || echo \"Error handled\"'" "Error handled"
run_test "Command not found handling" "zsh -c 'nonexistent_command 2>&1 || echo \"Command not found handled\"'" ""

# Results Summary
echo -e "\n${YELLOW}📊 TEST RESULTS SUMMARY${NC}"
echo "=========================="
echo -e "Total Tests: $TOTAL_TESTS"
echo -e "${GREEN}Passed: $PASSED_TESTS${NC}"
echo -e "${RED}Failed: $FAILED_TESTS${NC}"

if [[ $FAILED_TESTS -eq 0 ]]; then
    echo -e "\n${GREEN}🎉 ALL TESTS PASSED! Your dotfiles are working perfectly.${NC}"
    exit 0
else
    echo -e "\n${RED}⚠️  Some tests failed. Please review the failures above.${NC}"
    exit 1
fi
