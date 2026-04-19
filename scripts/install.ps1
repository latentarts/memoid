[CmdletBinding()]
param(
    [Parameter(Position=0)]
    [string]$WorkspaceArg,

    [switch]$Local
)

$ErrorActionPreference = "Stop"

$RepoUrl = if ($env:MEMOID_REPO_URL) { $env:MEMOID_REPO_URL } else { "https://github.com/prods/memoid.git" }
$DocumentsDir = [Environment]::GetFolderPath("MyDocuments")
$BaseDir = if ($env:MEMOID_BASE_DIR) { $env:MEMOID_BASE_DIR } else { Join-Path $DocumentsDir "memoid" }
$WorkspacesDir = if ($env:MEMOID_WORKSPACES_DIR) { $env:MEMOID_WORKSPACES_DIR } else { Join-Path $BaseDir "workspaces" }

function Require-Command {
    param([string]$Name)

    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        if ($Name -eq "uv") {
            Write-Host "uv is required for the Memoid runtime environment." -ForegroundColor Cyan
            $Choice = Read-Host "Would you like to install it now? [y/N]"
            if ($Choice -match "^[Yy]$") {
                Write-Host "Installing uv via astral.sh..." -ForegroundColor Cyan
                powershell -ExecutionPolicy Bypass -c "irm https://astral.sh/uv/install.ps1 | iex"
                if (-not (Get-Command "uv" -ErrorAction SilentlyContinue)) {
                    Write-Error "uv installation failed or is not in PATH. Please restart your shell and try again."
                    exit 1
                }
                return
            }
        }
        Write-Host "Missing required command: $Name" -ForegroundColor Red
        exit 1
    }
}

function Detect-Workspace {
    if (Test-Path ".memoid-workspace") {
        $config = Get-Content ".memoid-workspace" | ConvertFrom-StringData
        if ($config.WORKSPACE_NAME) {
            return @{
                Name = $config.WORKSPACE_NAME
                Dir  = Get-Location
            }
        }
    }
    return $null
}

function Prompt-WorkspaceName {
    param([string]$PassedName)

    if (-not [string]::IsNullOrWhiteSpace($PassedName)) {
        return $PassedName.Trim()
    }

    while ($true) {
        $name = (Read-Host "Workspace name").Trim()
        if ([string]::IsNullOrWhiteSpace($name)) {
            Write-Host "Workspace name cannot be empty" -ForegroundColor Yellow
            continue
        }
        if ($name.Contains("\") -or $name.Contains("/")) {
            Write-Host "Workspace name cannot contain path separators" -ForegroundColor Yellow
            continue
        }
        return $name
    }
}

function Ensure-RuntimeDirs {
    param([string]$WorkspaceDir)

    $dirs = @(
        "memory\raw\articles",
        "memory\raw\transcripts",
        "memory\raw\assets",
        "memory\raw\inbox",
        "memory\evidence\sessions",
        "memory\evidence\decisions",
        "memory\evidence\source-notes",
        "memory\evidence\audits"
    )

    foreach ($dir in $dirs) {
        New-Item -ItemType Directory -Force -Path (Join-Path $WorkspaceDir $dir) | Out-Null
    }
}

function Write-WorkspaceConfig {
    param(
        [string]$WorkspaceDir,
        [string]$WorkspaceName
    )

    $content = @(
        "REPO_URL=$RepoUrl"
        "WORKSPACE_NAME=$WorkspaceName"
    )
    Set-Content -Path (Join-Path $WorkspaceDir ".memoid-workspace") -Value $content
}

Require-Command git
Require-Command uv

$existing = Detect-Workspace
if ($null -ne $existing) {
    Write-Host "Detected existing workspace: $($existing.Name)"
    $WorkspaceName = $existing.Name
    $WorkspaceDir = $existing.Dir
} else {
    New-Item -ItemType Directory -Force -Path $WorkspacesDir | Out-Null
    $WorkspaceName = Prompt-WorkspaceName -PassedName $WorkspaceArg
    $WorkspaceDir = Join-Path $WorkspacesDir $WorkspaceName
    
    if (Test-Path $WorkspaceDir) {
        Write-Error "Error: Workspace directory $WorkspaceDir already exists."
        exit 1
    }

    if ($Local) {
        $CurrentRepoRoot = Split-Path -Parent $PSScriptRoot
        Write-Host "Local mode: cloning from $CurrentRepoRoot"
        git clone $CurrentRepoRoot $WorkspaceDir
    } else {
        Write-Host "Cloning Memoid from $RepoUrl into $WorkspaceDir"
        git clone $RepoUrl $WorkspaceDir
    }
}

Ensure-RuntimeDirs -WorkspaceDir $WorkspaceDir
Write-WorkspaceConfig -WorkspaceDir $WorkspaceDir -WorkspaceName $WorkspaceName

# Install memoid CLI dispatcher
$LocalBin = Join-Path $HOME ".local\bin"
if (-not (Test-Path $LocalBin)) {
    New-Item -ItemType Directory -Force -Path $LocalBin | Out-Null
}
$DispatcherSource = Join-Path $WorkspaceDir "scripts\memoid.ps1"
if (Test-Path $DispatcherSource) {
    Write-Host "Installing memoid CLI to $LocalBin\memoid.ps1"
    New-Item -ItemType SymbolicLink -Path (Join-Path $LocalBin "memoid.ps1") -Target $DispatcherSource -Force | Out-Null
}

Write-Host ""
Write-Host "Workspace ready: $WorkspaceDir"
Write-Host ""
Write-Host "Next step:"
Write-Host "  cd `"$WorkspaceDir`"; uv sync; uv run python scripts/post_init_check.py"
