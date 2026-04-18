# Memoid CLI Dispatcher
# Usage: memoid <workspace> <agent> [args...]

param(
    [Parameter(Mandatory=$false, Position=0)]
    [string]$WorkspaceName,

    [Parameter(Mandatory=$false, Position=1)]
    [string]$AgentCmd
)

$ErrorActionPreference = "Stop"

$DocumentsDir = [Environment]::GetFolderPath("MyDocuments")
$BaseDir = if ($env:MEMOID_BASE_DIR) { $env:MEMOID_BASE_DIR } else { Join-Path $DocumentsDir "memoid" }
$WorkspacesDir = if ($env:MEMOID_WORKSPACES_DIR) { $env:MEMOID_WORKSPACES_DIR } else { Join-Path $BaseDir "workspaces" }

function Show-Help {
    Write-Host "Usage: memoid <workspace> <agent> [args...]" -ForegroundColor Cyan
    Write-Host "       memoid new <workspace-name>" -ForegroundColor Cyan
    Write-Host "       memoid update" -ForegroundColor Cyan
    Write-Host "       memoid version" -ForegroundColor Cyan
    Write-Host "Example: memoid personal claude" -ForegroundColor Gray
}

if (-not $WorkspaceName) {
    Show-Help
    exit 1
}

# Handle version command
if ($WorkspaceName -eq "version") {
    $EngineDir = if ($env:MEMOID_ENGINE_DIR) { $env:MEMOID_ENGINE_DIR } else { Join-Path $BaseDir "memoid-engine" }
    if (Test-Path (Join-Path $EngineDir ".git")) {
        $Version = git -C $EngineDir describe --tags --always
        Write-Host "Memoid version: $Version"
    } else {
        Write-Host "Memoid version: unknown (engine not found)"
    }
    exit 0
}

# Handle new command
if ($WorkspaceName -eq "new") {
    if (-not $AgentCmd) {
        Write-Host "Usage: memoid new <workspace-name>" -ForegroundColor Red
        exit 1
    }
    $EngineDir = if ($env:MEMOID_ENGINE_DIR) { $env:MEMOID_ENGINE_DIR } else { Join-Path $BaseDir "memoid-engine" }
    $InstallScript = Join-Path $EngineDir "scripts\install.ps1"
    if (Test-Path $InstallScript) {
        & $InstallScript $AgentCmd
    } else {
        Write-Error "Error: Install script not found at $InstallScript"
        exit 1
    }
    exit 0
}

# Handle update command
if ($WorkspaceName -eq "update") {
    $EngineDir = if ($env:MEMOID_ENGINE_DIR) { $env:MEMOID_ENGINE_DIR } else { Join-Path $BaseDir "memoid-engine" }
    Write-Host "Updating Memoid engine in $EngineDir..." -ForegroundColor Cyan
    if (Test-Path (Join-Path $EngineDir ".git")) {
        git -C $EngineDir fetch --tags --prune
        
        # Get latest tag
        $LatestTag = (git -C $EngineDir tag --sort=-v:refname | Select-Object -First 1)
        
        if ($null -ne $LatestTag) {
            Write-Host "Switching to latest tag: $LatestTag"
            git -C $EngineDir checkout $LatestTag
        } else {
            Write-Host "No tags found, pulling latest from main..."
            git -C $EngineDir pull --ff-only
        }
        
        Write-Host "Memoid engine updated successfully." -ForegroundColor Green
        
        # If we are inside a workspace, offer to sync
        if (Test-Path ".memoid-workspace") {
            Write-Host "Detected workspace context. Running install script to sync engine changes..." -ForegroundColor Cyan
            & (Join-Path $EngineDir "scripts\install.ps1")
        }
    } else {
        Write-Error "Error: Engine repository not found at $EngineDir"
        exit 1
    }
    exit 0
}

if (-not $AgentCmd) {
    Show-Help
    exit 1
}

$WorkspaceDir = Join-Path $WorkspacesDir $WorkspaceName

if (-not (Test-Path $WorkspaceDir -PathType Container)) {
    Write-Error "Error: Workspace '$WorkspaceName' not found in $WorkspacesDir"
    exit 1
}

if (-not (Get-Command $AgentCmd -ErrorAction SilentlyContinue)) {
    Write-Error "Error: Agent command '$AgentCmd' not found in PATH"
    exit 1
}

# The remaining arguments are passed down to the agent command
$RemainingArgs = $args

Push-Location $WorkspaceDir
try {
    & $AgentCmd @RemainingArgs
} finally {
    Pop-Location
}
