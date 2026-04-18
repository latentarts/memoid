#!/usr/bin/env bash
set -euo pipefail

REPO_URL="${LOCI_REPO_URL:-https://github.com/prods/memoid.git}"
BASE_DIR="${LOCI_BASE_DIR:-$HOME/Documents/loci}"
ENGINE_DIR="${LOCI_ENGINE_DIR:-$BASE_DIR/memo-engine}"
WORKSPACES_DIR="${LOCI_WORKSPACES_DIR:-$BASE_DIR/workspaces}"
PRESERVE_DIRS=(raw evidence wiki agents)

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    printf 'missing required command: %s\n' "$1" >&2
    if [[ "$1" == "uv" ]]; then
      printf 'uv is required for the Memo runtime environment.\n'
      printf 'Would you like to install it now? [y/N] '
      read -r install_uv
      if [[ "$install_uv" =~ ^[Yy]$ ]]; then
        curl -LsSf https://astral.sh/uv/install.sh | sh
        # Source the newly installed uv if possible
        if [[ -f "$HOME/.local/bin/env" ]]; then
          # shellcheck disable=SC1091
          source "$HOME/.local/bin/env"
        elif [[ -f "$HOME/.cargo/bin/uv" ]]; then
          export PATH="$HOME/.cargo/bin:$PATH"
        fi
        
        # Check again
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
  if [[ -f ".loci-workspace" ]]; then
    # shellcheck disable=SC1091
    WORKSPACE_NAME=$(grep "WORKSPACE_NAME=" .loci-workspace | cut -d'=' -f2)
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

update_engine_repo() {
  mkdir -p "$BASE_DIR"
  if [[ -d "$ENGINE_DIR/.git" ]]; then
    printf 'Updating Memo engine repo in %s\n' "$ENGINE_DIR"
    git -C "$ENGINE_DIR" fetch --tags --prune
    git -C "$ENGINE_DIR" pull --ff-only
  else
    printf 'Cloning Memo engine repo into %s\n' "$ENGINE_DIR"
    git clone "$REPO_URL" "$ENGINE_DIR"
  fi
}

sync_engine_to_workspace() {
  local workspace_dir="$1"
  local -a rsync_args=(
    -a
    --delete
    --exclude
    ".git/"
    --exclude
    ".venv/"
    --exclude
    "__pycache__/"
    --exclude
    ".DS_Store"
    --exclude
    ".loci-workspace"
  )
  local dir
  for dir in "${PRESERVE_DIRS[@]}"; do
    rsync_args+=(--exclude "$dir/")
  done
  rsync "${rsync_args[@]}" "$ENGINE_DIR"/ "$workspace_dir"/
}

seed_data_directory() {
  local source_dir="$1"
  local target_dir="$2"
  if [[ -d "$target_dir" ]]; then
    # If directory exists, we don't overwrite, but we could sync NEW files.
    # For v1, we just skip as per spec.
    return
  fi
  mkdir -p "$target_dir"
  if [[ -d "$source_dir" ]]; then
    rsync -a "$source_dir"/ "$target_dir"/
  fi
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
  cat >"$workspace_dir/.loci-workspace" <<EOF
REPO_URL=$REPO_URL
ENGINE_DIR=$ENGINE_DIR
WORKSPACE_NAME=$WORKSPACE_NAME
EOF
}

main() {
  require_command git
  require_command rsync
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
  fi

  if [ "$LOCAL_MODE" = true ]; then
    # In local mode, the engine is the parent of the scripts directory
    ENGINE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
    printf 'Local mode: using engine from %s\n' "$ENGINE_DIR"
  else
    update_engine_repo
  fi

  mkdir -p "$WORKSPACE_DIR"
  printf 'Syncing engine files into %s\n' "$WORKSPACE_DIR"
  sync_engine_to_workspace "$WORKSPACE_DIR"

  seed_data_directory "$ENGINE_DIR/wiki" "$WORKSPACE_DIR/wiki"
  seed_data_directory "$ENGINE_DIR/agents" "$WORKSPACE_DIR/agents"
  ensure_runtime_dirs "$WORKSPACE_DIR"
  write_workspace_config "$WORKSPACE_DIR"

  # Install memoid CLI dispatcher
  mkdir -p "$HOME/.local/bin"
  if [[ -f "$ENGINE_DIR/scripts/memoid" ]]; then
    printf 'Installing memoid CLI to ~/.local/bin/memoid\n'
    ln -sf "$ENGINE_DIR/scripts/memoid" "$HOME/.local/bin/memoid"
  fi

  printf '\nWorkspace ready: %s\n' "$WORKSPACE_DIR"
  printf 'Memo engine repo: %s\n' "$ENGINE_DIR"
  printf '\nNext step:\n'
  printf '  cd "%s" && uv sync && uv run python scripts/post_init_check.py\n' "$WORKSPACE_DIR"
  printf '\nRe-running this script updates engine-managed files and preserves raw/, evidence/, wiki/, and agents/.\n'
}

main "$@"
