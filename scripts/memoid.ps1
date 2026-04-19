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
    Write-Host "       memoid ls" -ForegroundColor Cyan
    Write-Host "       memoid new <workspace-name>" -ForegroundColor Cyan
    Write-Host "       memoid update [workspace-name]" -ForegroundColor Cyan
    Write-Host "       memoid version [workspace-name]" -ForegroundColor Cyan
    Write-Host "Example: memoid personal claude" -ForegroundColor Gray
}

if (-not $WorkspaceName) {
    Show-Help
    exit 1
}

# Handle ls command
if ($WorkspaceName -eq "ls") {
    if (Test-Path $WorkspacesDir) {
        Write-Host "Existing workspaces in $WorkspacesDir:" -ForegroundColor Cyan
        Get-ChildItem $WorkspacesDir | Select-Object -ExpandProperty Name
    } else {
        Write-Host "No workspaces directory found at $WorkspacesDir" -ForegroundColor Yellow
    }
    exit 0
}

# Handle version command
if ($WorkspaceName -eq "version") {
    $TargetDir = Get-Location
    if ($AgentCmd) {
        $TargetDir = Join-Path $WorkspacesDir $AgentCmd
    }

    if (Test-Path (Join-Path $TargetDir ".git")) {
        $Version = git -C $TargetDir describe --tags --always
        Write-Host "Memoid version ($TargetDir): $Version"
    } else {
        Write-Host "Error: Target directory $TargetDir is not a git repository." -ForegroundColor Red
    }
    exit 0
}

# Handle new command
if ($WorkspaceName -eq "new") {
    if (-not $AgentCmd) {
        Write-Host "Usage: memoid new <workspace-name>" -ForegroundColor Red
        exit 1
    }
    # Find install.ps1 relative to current script
    $InstallScript = Join-Path $PSScriptRoot "install.ps1"
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
    $TargetDir = Get-Location
    if ($AgentCmd) {
        $TargetDir = Join-Path $WorkspacesDir $AgentCmd
    }

    if (-not (Test-Path (Join-Path $TargetDir ".git"))) {
        Write-Error "Error: Target directory $TargetDir is not a git repository."
        exit 1
    }

    Write-Host "Updating Memoid workspace in $TargetDir..." -ForegroundColor Cyan
    git -C $TargetDir fetch --tags --prune
    
    # Get latest tag
    $LatestTag = (git -C $TargetDir tag --sort=-v:refname | Select-Object -First 1)
    
    if ($null -ne $LatestTag) {
        Write-Host "Switching to latest tag: $LatestTag"
        git -C $TargetDir checkout $LatestTag
    } else {
        Write-Host "No tags found, pulling latest from main..."
        git -C $TargetDir pull --ff-only
    }
    
    Write-Host "Memoid workspace updated successfully." -ForegroundColor Green
    
    if (Test-Path (Join-Path $TargetDir "scripts\post_init_check.py")) {
        Write-Host "Running post-update check..."
        Push-Location $TargetDir
        try {
            uv run python scripts\post_init_check.py
        } finally {
            Pop-Location
        }
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

$RemainingArgs = $args

Push-Location $WorkspaceDir
try {
    & $AgentCmd @RemainingArgs
} finally {
    Pop-Location
}
