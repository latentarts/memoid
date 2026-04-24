#!/usr/bin/env bash
set -euo pipefail

# Memoid Ultimate Installer
# Handles: cloning, uv setup, init, and automatic MCP configuration for agents.

REPO_URL="https://github.com/latentarts/memoid.git"

# Utility: Print in color
printf_color() {
    local color_code=$1
    shift
    printf "\033[${color_code}m%s\033[0m\n" "$*"
}

info() { printf_color "34" "INFO: $*"; }
success() { printf_color "32" "SUCCESS: $*"; }
warn() { printf_color "33" "WARN: $*"; }
error() { printf_color "31" "ERROR: $*"; }

# 1. Path Selection
printf "Where would you like to install Memoid? [default: $HOME/memoid]: "
read -r INSTALL_PATH < /dev/tty 2>/dev/null || true
INSTALL_PATH="${INSTALL_PATH:-$HOME/memoid}"

if [[ -d "$INSTALL_PATH" ]]; then
    error "Directory $INSTALL_PATH already exists. Please remove it or choose a different path."
    exit 1
fi

# 2. UV Check/Install
if ! command -v uv &> /dev/null; then
    warn "uv (Python manager) not found."
    printf "Would you like to install uv now? [Y/n]: "
    read -r INSTALL_UV < /dev/tty 2>/dev/null || true
    if [[ ! "$INSTALL_UV" =~ ^[Nn]$ ]]; then
        info "Installing uv..."
        curl -LsSf https://astral.sh/uv/install.sh | sh
        # Source uv environment
        if [[ -f "$HOME/.local/bin/env" ]]; then
            source "$HOME/.local/bin/env"
        fi
        export PATH="$HOME/.cargo/bin:$HOME/.local/bin:$PATH"
    else
        error "uv is required for Memoid. Please install it and run this script again."
        exit 1
    fi
fi

# 3. Clone and Init
info "Cloning Memoid into $INSTALL_PATH..."
git clone "$REPO_URL" "$INSTALL_PATH"
cd "$INSTALL_PATH"

info "Initializing Memoid..."
uv sync
uv run python scripts/post_init_check.py

# 4. Global CLI Setup
mkdir -p "$HOME/.local/bin"
ln -sf "$INSTALL_PATH/scripts/memoid" "$HOME/.local/bin/memoid"
success "CLI 'memoid' installed to ~/.local/bin/memoid"

info "Running CLI smoke test..."
"$HOME/.local/bin/memoid" version >/dev/null
success "CLI smoke test passed"

# 5. MCP Setup
printf "\n"
info "To set up Memoid as an MCP server for your AI agent, please refer to the instructions in the README.md"

success "\nMemoid installation complete!"
info "Path: $INSTALL_PATH"
info "You can now run 'memoid gemini' or use it via MCP in your configured agents."
