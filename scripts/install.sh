#!/usr/bin/env bash
set -euo pipefail

# Memoid Ultimate Installer
# Handles: cloning, uv setup, memory initialization, and MCP setup guidance.

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

MCP_CONFIGURED_ANY=0

run_py() {
    UV_CACHE_DIR="${UV_CACHE_DIR:-/tmp/memoid-uv-cache}" uv run python - "$@"
}

json_config_has_memoid() {
    local config_path="$1"
    run_py "$config_path" <<'PY'
import json, sys
from pathlib import Path

path = Path(sys.argv[1])
if not path.exists():
    print("missing")
    raise SystemExit(0)
try:
    data = json.loads(path.read_text(encoding="utf-8") or "{}")
except Exception:
    print("invalid")
    raise SystemExit(0)

memoid = None
if isinstance(data.get("mcpServers"), dict):
    memoid = data["mcpServers"].get("memoid")
elif isinstance(data.get("mcp"), dict):
    memoid = data["mcp"].get("memoid")

print("present" if memoid else "absent")
PY
}

ensure_json_memoid() {
    local config_path="$1"
    local kind="$2"
    mkdir -p "$(dirname "$config_path")"
    if [[ ! -f "$config_path" ]]; then
        printf '{}\n' > "$config_path"
    fi

    run_py "$config_path" "$kind" <<'PY'
import json, sys
from pathlib import Path

path = Path(sys.argv[1])
kind = sys.argv[2]
data = json.loads(path.read_text(encoding="utf-8") or "{}")

if kind in {"claude", "gemini"}:
    data.setdefault("mcpServers", {})
    data["mcpServers"]["memoid"] = {
        "command": "memoid",
        "args": ["mcp"],
    }
elif kind == "opencode":
    data.setdefault("mcp", {})
    data["mcp"]["memoid"] = {
        "type": "local",
        "command": ["memoid", "mcp"],
        "enabled": True,
    }
else:
    raise SystemExit(f"Unsupported JSON config type: {kind}")

path.write_text(json.dumps(data, indent=2) + "\n", encoding="utf-8")
PY
}

validate_json_config() {
    local config_path="$1"
    local kind="$2"
    run_py "$config_path" "$kind" <<'PY'
import json, sys
from pathlib import Path

path = Path(sys.argv[1])
kind = sys.argv[2]
data = json.loads(path.read_text(encoding="utf-8"))
if kind in {"claude", "gemini"}:
    ok = isinstance(data.get("mcpServers"), dict) and "memoid" in data["mcpServers"]
elif kind == "opencode":
    ok = isinstance(data.get("mcp"), dict) and "memoid" in data["mcp"]
else:
    ok = False
raise SystemExit(0 if ok else 1)
PY
}

toml_config_has_memoid() {
    local config_path="$1"
    run_py "$config_path" <<'PY'
import re, sys
from pathlib import Path

path = Path(sys.argv[1])
if not path.exists():
    print("missing")
    raise SystemExit(0)
text = path.read_text(encoding="utf-8")
print("present" if re.search(r'^\[mcp_servers\.memoid\]\s*$', text, re.MULTILINE) else "absent")
PY
}

ensure_codex_memoid() {
    local config_path="$1"
    mkdir -p "$(dirname "$config_path")"
    touch "$config_path"
    if toml_config_has_memoid "$config_path" | grep -q '^present$'; then
        return
    fi
    if [[ -s "$config_path" ]]; then
        printf '\n' >> "$config_path"
    fi
    cat >> "$config_path" <<'EOF'
[mcp_servers.memoid]
command = "memoid"
args = ["mcp"]
EOF
}

validate_codex_config() {
    local config_path="$1"
    run_py "$config_path" <<'PY'
import re, sys, tomllib
from pathlib import Path

path = Path(sys.argv[1])
text = path.read_text(encoding="utf-8")
data = tomllib.loads(text)
ok = isinstance(data.get("mcp_servers"), dict) and "memoid" in data["mcp_servers"]
raise SystemExit(0 if ok else 1)
PY
}

detect_agent_binary() {
    local binary="$1"
    if command -v "$binary" >/dev/null 2>&1; then
        return 0
    fi
    return 1
}

config_path_for() {
    local agent="$1"
    case "$agent" in
        claude)
            if [[ "$(uname -s)" == "Darwin" ]]; then
                printf '%s\n' "$HOME/Library/Application Support/Claude/claude_desktop_config.json"
            else
                printf '%s\n' "${XDG_CONFIG_HOME:-$HOME/.config}/Claude/claude_desktop_config.json"
            fi
            ;;
        gemini)
            printf '%s\n' "$HOME/.gemini/settings.json"
            ;;
        opencode)
            if [[ "$(uname -s)" == "Darwin" && -e "$HOME/Library/Application Support/opencode/opencode.json" ]]; then
                printf '%s\n' "$HOME/Library/Application Support/opencode/opencode.json"
            else
                printf '%s\n' "${XDG_CONFIG_HOME:-$HOME/.config}/opencode/opencode.json"
            fi
            ;;
        codex)
            printf '%s\n' "$HOME/.codex/config.toml"
            ;;
    esac
}

status_for_agent() {
    local agent="$1"
    local config_path="$2"
    case "$agent" in
        claude|gemini|opencode) json_config_has_memoid "$config_path" ;;
        codex) toml_config_has_memoid "$config_path" ;;
    esac
}

backup_file() {
    local path="$1"
    local timestamp
    timestamp="$(date +%Y%m%d%H%M%S)"
    if [[ -f "$path" ]]; then
        cp "$path" "${path}.bak.${timestamp}"
        printf '%s\n' "${path}.bak.${timestamp}"
    else
        printf '%s\n' ""
    fi
}

configure_detected_mcp_clients() {
    local agents=("claude" "codex" "gemini" "opencode")
    local selectable=()

    printf '\n'
    printf "Would you like Memoid to check your installed AI agents and offer to configure MCP automatically? [Y/n]: "
    local configure_choice
    read -r configure_choice < /dev/tty 2>/dev/null || true
    if [[ "$configure_choice" =~ ^[Nn]$ ]]; then
        info "Skipping automatic MCP client configuration."
        return
    fi

    printf '\n'
    info "Checking installed AI agents and their MCP configs..."

    for agent in "${agents[@]}"; do
        local config_path status
        config_path="$(config_path_for "$agent")"
        if detect_agent_binary "$agent"; then
            status="$(status_for_agent "$agent" "$config_path")"
            case "$status" in
                present)
                    info " - $agent: installed, config ready, Memoid MCP already configured ($config_path)"
                    ;;
                absent)
                    info " - $agent: installed, config found or will be created, Memoid MCP missing ($config_path)"
                    selectable+=("$agent")
                    ;;
                missing)
                    info " - $agent: installed, config not found yet, will create if selected ($config_path)"
                    selectable+=("$agent")
                    ;;
                invalid)
                    warn " - $agent: installed, but config is invalid JSON and was skipped ($config_path)"
                    ;;
            esac
        else
            info " - $agent: not installed"
        fi
    done

    if [[ ${#selectable[@]} -eq 0 ]]; then
        info "No installed agent configs require Memoid MCP setup."
        return
    fi

    printf '\n'
    info "Select which agent configs to update with the Memoid MCP entry."
    info "Enter one or more names separated by spaces, or 'all' to update every detected config."
    printf "Selection [%s]: " "${selectable[*]}"
    local selection
    read -r selection < /dev/tty 2>/dev/null || true
    selection="${selection:-all}"

    local chosen=()
    if [[ "$selection" == "all" ]]; then
        chosen=("${selectable[@]}")
    else
        for item in $selection; do
            for candidate in "${selectable[@]}"; do
                if [[ "$item" == "$candidate" ]]; then
                    chosen+=("$candidate")
                fi
            done
        done
    fi

    if [[ ${#chosen[@]} -eq 0 ]]; then
        warn "No valid agent selections were provided. Skipping MCP config updates."
        return
    fi

    for agent in "${chosen[@]}"; do
        local config_path backup_path
        config_path="$(config_path_for "$agent")"
        backup_path="$(backup_file "$config_path")"
        [[ -n "$backup_path" ]] && info "Backed up $agent config to $backup_path"

        case "$agent" in
            claude|gemini|opencode)
                ensure_json_memoid "$config_path" "$agent"
                validate_json_config "$config_path" "$agent"
                ;;
            codex)
                ensure_codex_memoid "$config_path"
                validate_codex_config "$config_path"
                ;;
        esac
        success "Configured Memoid MCP for $agent at $config_path"
        MCP_CONFIGURED_ANY=1
    done
}

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

# 3. Clone
info "Cloning Memoid into $INSTALL_PATH..."
git clone "$REPO_URL" "$INSTALL_PATH"
cd "$INSTALL_PATH"

# 4. Global CLI Setup
mkdir -p "$HOME/.local/bin"
ln -sf "$INSTALL_PATH/scripts/memoid" "$HOME/.local/bin/memoid"
success "CLI 'memoid' installed to ~/.local/bin/memoid"

info "Running CLI smoke test..."
"$HOME/.local/bin/memoid" version >/dev/null
success "CLI smoke test passed"

info "Initializing Memoid memory..."
"$HOME/.local/bin/memoid" init
success "Memoid memory initialized"

# 5. MCP Setup
configure_detected_mcp_clients

if [[ "$MCP_CONFIGURED_ANY" -eq 0 ]]; then
    printf "\n"
    info "To set up Memoid as an MCP server for your AI agent, please refer to the instructions in the README.md"
fi

success "\nMemoid installation complete!"
info "Path: $INSTALL_PATH"
info "You can now run 'memoid gemini' or use it via MCP in your configured agents."
