#!/usr/bin/env bash
set -euo pipefail

REPO_URL="${MEMOID_REPO_URL:-https://github.com/prods/memoid.git}"
BASE_DIR="${MEMOID_BASE_DIR:-$HOME/Documents/memoid}"
WORKSPACES_DIR="${MEMOID_WORKSPACES_DIR:-$BASE_DIR/workspaces}"

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    printf 'missing required command: %s\n' "$1" >&2
    if [[ "$1" == "uv" ]]; then
      printf 'uv is required for the Memoid runtime environment.\n'
      printf 'Would you like to install it now? [y/N] '
      read -r install_uv
      if [[ "$install_uv" =~ ^[Yy]$ ]]; then
        curl -LsSf https://astral.sh/uv/install.sh | sh
        if [[ -f "$HOME/.local/bin/env" ]]; then
          source "$HOME/.local/bin/env"
        elif [[ -f "$HOME/.cargo/bin/uv" ]]; then
          export PATH="$HOME/.cargo/bin:$PATH"
        fi
        
        if ! command -v uv >/dev/null 2>&1; then
          printf 'uv installation failed or is not in PATH. Please restart your shell and try again.\n' >&2
          exit 1
        fi
        return 0
      else
        printf 'tip: install uv manually from https://github.com/astral-sh/uv\n' >&2
      fi
    fi
    exit 1
  fi
}

detect_workspace() {
  if [[ -f ".memoid-workspace" ]]; then
    WORKSPACE_NAME=$(grep "WORKSPACE_NAME=" .memoid-workspace | cut -d'=' -f2)
    if [[ -n "$WORKSPACE_NAME" ]]; then
      WORKSPACE_DIR=$(pwd)
      return 0
    fi
  fi
  return 1
}

prompt_workspace_name() {
  if [[ -n "${1:-}" ]]; then
    WORKSPACE_NAME="$1"
    return
  fi

  local workspace_name
  while true; do
    printf 'Workspace name: '
    read -r workspace_name
    workspace_name="${workspace_name#"${workspace_name%%[![:space:]]*}"}"
    workspace_name="${workspace_name%"${workspace_name##*[![:space:]]}"}"
    if [[ -z "$workspace_name" ]]; then
      printf 'workspace name cannot be empty\n' >&2
      continue
    fi
    if [[ "$workspace_name" == *"/"* || "$workspace_name" == *"\\"* ]]; then
      printf 'workspace name cannot contain path separators\n' >&2
      continue
    fi
    WORKSPACE_NAME="$workspace_name"
    return
  done
}

ensure_runtime_dirs() {
  local workspace_dir="$1"
  mkdir -p \
    "$workspace_dir/raw/articles" \
    "$workspace_dir/raw/transcripts" \
    "$workspace_dir/raw/assets" \
    "$workspace_dir/raw/inbox" \
    "$workspace_dir/evidence/sessions" \
    "$workspace_dir/evidence/decisions" \
    "$workspace_dir/evidence/source-notes" \
    "$workspace_dir/evidence/audits"
}

write_workspace_config() {
  local workspace_dir="$1"
  cat >"$workspace_dir/.memoid-workspace" <<EOF
REPO_URL=$REPO_URL
WORKSPACE_NAME=$WORKSPACE_NAME
EOF
}

main() {
  require_command git
  require_command uv

  LOCAL_MODE=false
  WORKSPACE_ARG=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --local)
        LOCAL_MODE=true
        shift
        ;;
      *)
        WORKSPACE_ARG="$1"
        shift
        ;;
    esac
  done

  if detect_workspace; then
    printf 'Detected existing workspace: %s\n' "$WORKSPACE_NAME"
  else
    mkdir -p "$WORKSPACES_DIR"
    prompt_workspace_name "$WORKSPACE_ARG"
    WORKSPACE_DIR="$WORKSPACES_DIR/$WORKSPACE_NAME"
    
    if [[ -d "$WORKSPACE_DIR" ]]; then
      printf 'Error: Workspace directory %s already exists.\n' "$WORKSPACE_DIR" >&2
      exit 1
    fi

    if [ "$LOCAL_MODE" = true ]; then
      local current_repo_root
      current_repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
      printf 'Local mode: cloning from %s\n' "$current_repo_root"
      git clone "$current_repo_root" "$WORKSPACE_DIR"
    else
      printf 'Cloning Memoid from %s into %s\n' "$REPO_URL" "$WORKSPACE_DIR"
      git clone "$REPO_URL" "$WORKSPACE_DIR"
    fi
  fi

  ensure_runtime_dirs "$WORKSPACE_DIR"
  write_workspace_config "$WORKSPACE_DIR"

  # Install memoid CLI dispatcher from the new workspace
  mkdir -p "$HOME/.local/bin"
  if [[ -f "$WORKSPACE_DIR/scripts/memoid" ]]; then
    printf 'Installing memoid CLI to ~/.local/bin/memoid\n'
    ln -sf "$WORKSPACE_DIR/scripts/memoid" "$HOME/.local/bin/memoid"
  fi

  printf '\nWorkspace ready: %s\n' "$WORKSPACE_DIR"
  printf '\nNext step:\n'
  printf '  cd "%s" && uv sync && uv run python scripts/post_init_check.py\n' "$WORKSPACE_DIR"
}

main "$@"
