[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"

$RepoUrl = if ($env:LOCI_REPO_URL) { $env:LOCI_REPO_URL } else { "https://github.com/prods/memoid.git" }
$DocumentsDir = [Environment]::GetFolderPath("MyDocuments")
$BaseDir = if ($env:LOCI_BASE_DIR) { $env:LOCI_BASE_DIR } else { Join-Path $DocumentsDir "loci" }
$EngineDir = if ($env:LOCI_ENGINE_DIR) { $env:LOCI_ENGINE_DIR } else { Join-Path $BaseDir "memo-engine" }
$WorkspacesDir = if ($env:LOCI_WORKSPACES_DIR) { $env:LOCI_WORKSPACES_DIR } else { Join-Path $BaseDir "workspaces" }
$PreserveDirs = @("raw", "evidence", "wiki", "agents")

function Require-Command {
    param([string]$Name)

    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        if ($Name -eq "uv") {
            Write-Host "uv is required for the Memo runtime environment." -ForegroundColor Cyan
            $Choice = Read-Host "Would you like to install it now? [y/N]"
            if ($Choice -match "^[Yy]$") {
                Write-Host "Installing uv via astral.sh..." -ForegroundColor Cyan
                powershell -ExecutionPolicy Bypass -c "irm https://astral.sh/uv/install.ps1 | iex"
                
                # Check again
                if (-not (Get-Command "uv" -ErrorAction SilentlyContinue)) {
                    Write-Error "uv installation failed or is not in PATH. Please restart your shell and try again."
                    exit 1
                }
                return
            } else {
                Write-Host "Tip: install uv from https://github.com/astral-sh/uv" -ForegroundColor Cyan
            }
        }
        Write-Host "Missing required command: $Name" -ForegroundColor Red
        exit 1
    }
}

function Detect-Workspace {
    if (Test-Path ".loci-workspace") {
        $config = Get-Content ".loci-workspace" | ConvertFrom-StringData
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

function Update-EngineRepo {
    New-Item -ItemType Directory -Force -Path $BaseDir | Out-Null
    if (Test-Path (Join-Path $EngineDir ".git")) {
        Write-Host "Updating Memo engine repo in $EngineDir"
        git -C $EngineDir fetch --tags --prune
        git -C $EngineDir pull --ff-only
    } else {
        Write-Host "Cloning Memo engine repo into $EngineDir"
        git clone $RepoUrl $EngineDir
    }
}

function Sync-EngineToWorkspace {
    param([string]$WorkspaceDir)

    $xd = @(".git", ".venv", "__pycache__", ".loci-workspace") + $PreserveDirs
    $arguments = @(
        $EngineDir,
        $WorkspaceDir,
        "/MIR",
        "/XD"
    ) + $xd + @(
        "/XF",
        ".DS_Store",
        "/R:1",
        "/W:1",
        "/NFL",
        "/NDL",
        "/NJH",
        "/NJS",
        "/NP"
    )

    & robocopy @arguments | Out-Null
    $exitCode = $LASTEXITCODE
    if ($exitCode -ge 8) {
        throw "robocopy failed with exit code $exitCode"
    }
}

function Seed-DataDirectory {
    param(
        [string]$SourceDir,
        [string]$TargetDir
    )

    if (Test-Path $TargetDir) {
        return
    }

    New-Item -ItemType Directory -Force -Path $TargetDir | Out-Null
    if (Test-Path $SourceDir) {
        & robocopy $SourceDir $TargetDir "/E" "/R:1" "/W:1" "/NFL" "/NDL" "/NJH" "/NJS" "/NP" | Out-Null
        $exitCode = $LASTEXITCODE
        if ($exitCode -ge 8) {
            throw "robocopy failed while seeding $TargetDir with exit code $exitCode"
        }
    }
}

function Ensure-RuntimeDirs {
    param([string]$WorkspaceDir)

    $dirs = @(
        "raw\articles",
        "raw\transcripts",
        "raw\assets",
        "raw\inbox",
        "evidence\sessions",
        "evidence\decisions",
        "evidence\source-notes",
        "evidence\audits"
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
        "ENGINE_DIR=$EngineDir"
        "WORKSPACE_NAME=$WorkspaceName"
    )
    Set-Content -Path (Join-Path $WorkspaceDir ".loci-workspace") -Value $content
}

Require-Command git
Require-Command robocopy
Require-Command uv

$existing = Detect-Workspace
if ($null -ne $existing) {
    Write-Host "Detected existing workspace: $($existing.Name)"
    $WorkspaceName = $existing.Name
    $WorkspaceDir = $existing.Dir
} else {
    New-Item -ItemType Directory -Force -Path $WorkspacesDir | Out-Null
    $WorkspaceName = Prompt-WorkspaceName -PassedName ($args[0])
    $WorkspaceDir = Join-Path $WorkspacesDir $WorkspaceName
}

Update-EngineRepo

New-Item -ItemType Directory -Force -Path $WorkspaceDir | Out-Null

Write-Host "Syncing engine files into $WorkspaceDir"
Sync-EngineToWorkspace -WorkspaceDir $WorkspaceDir

Seed-DataDirectory -SourceDir (Join-Path $EngineDir "wiki") -TargetDir (Join-Path $WorkspaceDir "wiki")
Seed-DataDirectory -SourceDir (Join-Path $EngineDir "agents") -TargetDir (Join-Path $WorkspaceDir "agents")
Ensure-RuntimeDirs -WorkspaceDir $WorkspaceDir
Write-WorkspaceConfig -WorkspaceDir $WorkspaceDir -WorkspaceName $WorkspaceName

# Install memoid CLI dispatcher
$LocalBin = Join-Path $HOME ".local\bin"
if (-not (Test-Path $LocalBin)) {
    New-Item -ItemType Directory -Force -Path $LocalBin | Out-Null
}
$DispatcherSource = Join-Path $EngineDir "scripts\memoid.ps1"
if (Test-Path $DispatcherSource) {
    Write-Host "Installing memoid CLI to $LocalBin\memoid.ps1"
    # Create a small cmd or ps1 wrapper if needed, but for now we just link the script
    New-Item -ItemType SymbolicLink -Path (Join-Path $LocalBin "memoid.ps1") -Target $DispatcherSource -Force | Out-Null
}

Write-Host ""
Write-Host "Workspace ready: $WorkspaceDir"
Write-Host "Memo engine repo: $EngineDir"
Write-Host ""
Write-Host "Next step:"
Write-Host "  cd `"$WorkspaceDir`"; uv sync; uv run python scripts/post_init_check.py"
Write-Host ""
Write-Host "Re-running this script updates engine-managed files and preserves raw/, evidence/, wiki/, and agents/."
