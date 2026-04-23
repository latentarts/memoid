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

# 5. MCP Setup
printf "\n"
info "Scanning for AI agents to configure MCP..."
AGENTS_FOUND=0

# --- Helper: Update JSON Config ---
update_mcp_config() {
    local config_file=$1
    local name="memoid"
    local command="uv"
    local dir=$INSTALL_PATH

    # Create backup
    cp "$config_file" "${config_file}.bak"
    info "Created backup: ${config_file}.bak"

    # Use python to safely update JSON (since we know uv/python is available)
    uv run python -c "
import json, os
path = '$config_file'
with open(path, 'r') as f:
    data = json.load(f)
if 'mcpServers' not in data:
    data['mcpServers'] = {}
data['mcpServers']['$name'] = {
    'command': '$command',
    'args': ['--directory', '$dir', 'run', 'scripts/mcp_server.py']
}
with open(path, 'w') as f:
    json.dump(data, f, indent=2)
"
}

# --- Check Claude Desktop ---
CLAUDE_CONFIG=""
if [[ "$OSTYPE" == "darwin"* ]]; then
    CLAUDE_CONFIG="$HOME/Library/Application Support/Claude/claude_desktop_config.json"
else
    CLAUDE_CONFIG="$HOME/.config/Claude/claude_desktop_config.json"
fi

if [[ -f "$CLAUDE_CONFIG" ]]; then
    AGENTS_FOUND=$((AGENTS_FOUND + 1))
    printf "Found Claude Desktop configuration. Install Memoid MCP? [Y/n]: "
    read -r CONFIRM < /dev/tty 2>/dev/null || true
    if [[ ! "$CONFIRM" =~ ^[Nn]$ ]]; then
        update_mcp_config "$CLAUDE_CONFIG"
        success "Claude Desktop MCP configured."
    fi
fi

# --- Check OpenCode (Similar to Cursor) ---
OPENCODE_CONFIG="$HOME/.opencode/config.json" # Best guess for OpenCode path
if [[ -f "$OPENCODE_CONFIG" ]]; then
    AGENTS_FOUND=$((AGENTS_FOUND + 1))
    printf "Found OpenCode configuration. Install Memoid MCP? [Y/n]: "
    read -r CONFIRM < /dev/tty 2>/dev/null || true
    if [[ ! "$CONFIRM" =~ ^[Nn]$ ]]; then
        update_mcp_config "$OPENCODE_CONFIG"
        success "OpenCode MCP configured."
    fi
fi

if [[ $AGENTS_FOUND -eq 0 ]]; then
    warn "No common AI agent configurations (Claude Desktop, etc.) were found automatically."
    info "To set up MCP manually, refer to the README.md in $INSTALL_PATH"
fi

success "\nMemoid installation complete!"
info "Path: $INSTALL_PATH"
info "You can now run 'memoid gemini' or use it via MCP in your configured agents."
