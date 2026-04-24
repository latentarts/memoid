# Memoid Ultimate Installer for Windows
# Handles: cloning, uv setup, init, and automatic MCP configuration.

$RepoUrl = "https://github.com/latentarts/memoid.git"

function Write-Info ($msg) { Write-Host "INFO: $msg" -ForegroundColor Blue }
function Write-Success ($msg) { Write-Host "SUCCESS: $msg" -ForegroundColor Green }
function Write-Warn ($msg) { Write-Host "WARN: $msg" -ForegroundColor Yellow }
function Write-Error ($msg) { Write-Host "ERROR: $msg" -ForegroundColor Red }

# 1. Path Selection
$DefaultPath = Join-Path $HOME "memoid"
$InstallPath = Read-Host "Where would you like to install Memoid? [default: $DefaultPath]"
if (-not $InstallPath) { $InstallPath = $DefaultPath }

if (Test-Path $InstallPath) {
    Write-Error "Directory $InstallPath already exists. Please remove it or choose a different path."
    exit 1
}

# 2. UV Check/Install
if (-not (Get-Command uv -ErrorAction SilentlyContinue)) {
    Write-Warn "uv (Python manager) not found."
    $InstallUv = Read-Host "Would you like to install uv now? [Y/n]"
    if ($InstallUv -notmatch "^[Nn]") {
        Write-Info "Installing uv..."
        powershell -ExecutionPolicy Bypass -c "irm https://astral.sh/uv/install.ps1 | iex"
        # Refresh path
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","User") + ";" + [System.Environment]::GetEnvironmentVariable("Path","Machine")
    } else {
        Write-Error "uv is required for Memoid. Please install it and run this script again."
        exit 1
    }
}

# 3. Clone and Init
Write-Info "Cloning Memoid into $InstallPath..."
git clone $RepoUrl $InstallPath
Set-Location $InstallPath

Write-Info "Initializing Memoid..."
uv sync
uv run python scripts/post_init_check.py

# 4. Global CLI Setup (Adding to User Path)
Write-Info "Checking for scripts directory in PATH..."
$ScriptsDir = Join-Path $HOME "Documents\WindowsPowerShell\Scripts"
if (-not (Test-Path $ScriptsDir)) { New-Item -ItemType Directory -Path $ScriptsDir -Force }

$DestFile = Join-Path $ScriptsDir "memoid.ps1"
Copy-Item "scripts\memoid.ps1" $DestFile -Force
Write-Success "CLI 'memoid' installed to $DestFile"

# 5. MCP Setup
Write-Host ""
Write-Info "To set up Memoid as an MCP server for your AI agent, please refer to the instructions in the README.md"

Write-Success "`nMemoid installation complete!"
Write-Info "Path: $InstallPath"
Write-Info "You can now run 'memoid gemini' or use it via MCP in your configured agents."
