# Memoid Ultimate Installer for Windows
# Handles: cloning, uv setup, memory initialization, and MCP setup guidance.

$RepoUrl = "https://github.com/latentarts/memoid.git"

function Write-Info ($msg) { Write-Host "INFO: $msg" -ForegroundColor Blue }
function Write-Success ($msg) { Write-Host "SUCCESS: $msg" -ForegroundColor Green }
function Write-Warn ($msg) { Write-Host "WARN: $msg" -ForegroundColor Yellow }
function Write-Error ($msg) { Write-Host "ERROR: $msg" -ForegroundColor Red }

$McpConfiguredAny = $false

function Invoke-UvPython {
    param(
        [string]$Code,
        [string[]]$Arguments = @()
    )

    $cacheDir = Join-Path $env:TEMP "memoid-uv-cache"
    if (-not (Test-Path $cacheDir)) {
        New-Item -ItemType Directory -Path $cacheDir -Force | Out-Null
    }

    $oldCache = $env:UV_CACHE_DIR
    $env:UV_CACHE_DIR = $cacheDir
    try {
        $psi = New-Object System.Diagnostics.ProcessStartInfo
        $psi.FileName = "uv"
        $psi.ArgumentList.Add("run")
        $psi.ArgumentList.Add("python")
        $psi.ArgumentList.Add("-")
        foreach ($arg in $Arguments) {
            $psi.ArgumentList.Add($arg)
        }
        $psi.RedirectStandardInput = $true
        $psi.RedirectStandardOutput = $true
        $psi.RedirectStandardError = $true
        $psi.UseShellExecute = $false
        $process = [System.Diagnostics.Process]::Start($psi)
        $process.StandardInput.Write($Code)
        $process.StandardInput.Close()
        $stdout = $process.StandardOutput.ReadToEnd()
        $stderr = $process.StandardError.ReadToEnd()
        $process.WaitForExit()
        return [pscustomobject]@{
            ExitCode = $process.ExitCode
            StdOut = $stdout.Trim()
            StdErr = $stderr.Trim()
        }
    } finally {
        $env:UV_CACHE_DIR = $oldCache
    }
}

function Get-AgentConfigPath {
    param([string]$Agent)
    switch ($Agent) {
        "claude" { return Join-Path $env:APPDATA "Claude\claude_desktop_config.json" }
        "gemini" { return Join-Path $HOME ".gemini\settings.json" }
        "opencode" { return Join-Path $env:APPDATA "opencode\opencode.json" }
        "codex" { return Join-Path $HOME ".codex\config.toml" }
        default { throw "Unknown agent: $Agent" }
    }
}

function Get-AgentConfigStatus {
    param(
        [string]$Agent,
        [string]$ConfigPath
    )

    if ($Agent -eq "codex") {
        if (-not (Test-Path $ConfigPath)) { return "missing" }
        $result = Invoke-UvPython -Code @'
import re, sys
from pathlib import Path
path = Path(sys.argv[1])
text = path.read_text(encoding="utf-8")
print("present" if re.search(r"^\[mcp_servers\.memoid\]\s*$", text, re.MULTILINE) else "absent")
'@ -Arguments @($ConfigPath)
        return $result.StdOut
    }

    if (-not (Test-Path $ConfigPath)) { return "missing" }
    try {
        $json = Get-Content $ConfigPath -Raw | ConvertFrom-Json -ErrorAction Stop
    } catch {
        return "invalid"
    }

    if ($Agent -in @("claude", "gemini")) {
        if ($json.mcpServers -and $json.mcpServers.memoid) { return "present" }
        return "absent"
    }
    if ($Agent -eq "opencode") {
        if ($json.mcp -and $json.mcp.memoid) { return "present" }
        return "absent"
    }
    return "absent"
}

function Backup-Config {
    param([string]$ConfigPath)
    if (-not (Test-Path $ConfigPath)) { return $null }
    $timestamp = Get-Date -Format "yyyyMMddHHmmss"
    $backupPath = "$ConfigPath.bak.$timestamp"
    Copy-Item $ConfigPath $backupPath -Force
    return $backupPath
}

function Ensure-JsonMemoidConfig {
    param(
        [string]$ConfigPath,
        [string]$Agent
    )

    $dir = Split-Path $ConfigPath -Parent
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    if (-not (Test-Path $ConfigPath)) { "{}" | Set-Content $ConfigPath -Encoding UTF8 }
    $result = Invoke-UvPython -Code @'
import json, sys
from pathlib import Path

path = Path(sys.argv[1])
agent = sys.argv[2]
data = json.loads(path.read_text(encoding="utf-8") or "{}")

if agent in {"claude", "gemini"}:
    data.setdefault("mcpServers", {})
    data["mcpServers"]["memoid"] = {
        "command": "memoid",
        "args": ["mcp"],
    }
elif agent == "opencode":
    data.setdefault("mcp", {})
    data["mcp"]["memoid"] = {
        "type": "local",
        "command": ["memoid", "mcp"],
        "enabled": True,
    }
else:
    raise SystemExit(f"Unsupported agent: {agent}")

path.write_text(json.dumps(data, indent=2) + "\n", encoding="utf-8")
'@ -Arguments @($ConfigPath, $Agent)
    if ($result.ExitCode -ne 0) {
        throw "Failed to update $Agent config at $ConfigPath. $($result.StdErr)"
    }
}

function Validate-JsonMemoidConfig {
    param(
        [string]$ConfigPath,
        [string]$Agent
    )
    $result = Invoke-UvPython -Code @'
import json, sys
from pathlib import Path

path = Path(sys.argv[1])
agent = sys.argv[2]
data = json.loads(path.read_text(encoding="utf-8"))
if agent in {"claude", "gemini"}:
    ok = isinstance(data.get("mcpServers"), dict) and "memoid" in data["mcpServers"]
elif agent == "opencode":
    ok = isinstance(data.get("mcp"), dict) and "memoid" in data["mcp"]
else:
    ok = False
raise SystemExit(0 if ok else 1)
'@ -Arguments @($ConfigPath, $Agent)
    return ($result.ExitCode -eq 0)
}

function Ensure-CodexMemoidConfig {
    param([string]$ConfigPath)
    $dir = Split-Path $ConfigPath -Parent
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    if (-not (Test-Path $ConfigPath)) { New-Item -ItemType File -Path $ConfigPath -Force | Out-Null }

    $status = Get-AgentConfigStatus -Agent "codex" -ConfigPath $ConfigPath
    if ($status -eq "present") { return }

    $existing = Get-Content $ConfigPath -Raw
    $block = @"
[mcp_servers.memoid]
command = "memoid"
args = ["mcp"]
"@
    if ($existing.Trim()) {
        Add-Content -Path $ConfigPath -Value "`r`n$block"
    } else {
        Set-Content -Path $ConfigPath -Value $block -Encoding UTF8
    }
}

function Validate-CodexMemoidConfig {
    param([string]$ConfigPath)
    $result = Invoke-UvPython -Code @'
import sys, tomllib
from pathlib import Path
path = Path(sys.argv[1])
data = tomllib.loads(path.read_text(encoding="utf-8"))
raise SystemExit(0 if isinstance(data.get("mcp_servers"), dict) and "memoid" in data["mcp_servers"] else 1)
'@ -Arguments @($ConfigPath)
    return ($result.ExitCode -eq 0)
}

function Configure-DetectedMcpClients {
    $agents = @("claude", "codex", "gemini", "opencode")
    $selectable = New-Object System.Collections.Generic.List[string]

    Write-Host ""
    $configureChoice = Read-Host "Would you like Memoid to check your installed AI agents and offer to configure MCP automatically? [Y/n]"
    if ($configureChoice -match "^[Nn]") {
        Write-Info "Skipping automatic MCP client configuration."
        return
    }

    Write-Host ""
    Write-Info "Checking installed AI agents and their MCP configs..."

    foreach ($agent in $agents) {
        if (Get-Command $agent -ErrorAction SilentlyContinue) {
            $configPath = Get-AgentConfigPath -Agent $agent
            $status = Get-AgentConfigStatus -Agent $agent -ConfigPath $configPath
            switch ($status) {
                "present" { Write-Info " - $agent: installed, config ready, Memoid MCP already configured ($configPath)" }
                "absent" {
                    Write-Info " - $agent: installed, config found or will be created, Memoid MCP missing ($configPath)"
                    $selectable.Add($agent) | Out-Null
                }
                "missing" {
                    Write-Info " - $agent: installed, config not found yet, will create if selected ($configPath)"
                    $selectable.Add($agent) | Out-Null
                }
                "invalid" { Write-Warn " - $agent: installed, but config is invalid and was skipped ($configPath)" }
                default { Write-Warn " - $agent: installed, but status could not be determined ($configPath)" }
            }
        } else {
            Write-Info " - $agent: not installed"
        }
    }

    if ($selectable.Count -eq 0) {
        Write-Info "No installed agent configs require Memoid MCP setup."
        return
    }

    Write-Host ""
    Write-Info "Select which agent configs to update with the Memoid MCP entry."
    Write-Info "Enter one or more names separated by spaces, or 'all' to update every detected config."
    $selection = Read-Host "Selection [$($selectable -join ' ')]"
    if (-not $selection) { $selection = "all" }

    $chosen = @()
    if ($selection -eq "all") {
        $chosen = $selectable
    } else {
        foreach ($item in ($selection -split "\s+")) {
            if ($selectable -contains $item) {
                $chosen += $item
            }
        }
    }

    if ($chosen.Count -eq 0) {
        Write-Warn "No valid agent selections were provided. Skipping MCP config updates."
        return
    }

    foreach ($agent in $chosen) {
        $configPath = Get-AgentConfigPath -Agent $agent
        $backupPath = Backup-Config -ConfigPath $configPath
        if ($backupPath) { Write-Info "Backed up $agent config to $backupPath" }

        switch ($agent) {
            "claude" { Ensure-JsonMemoidConfig -ConfigPath $configPath -Agent $agent; $ok = Validate-JsonMemoidConfig -ConfigPath $configPath -Agent $agent }
            "gemini" { Ensure-JsonMemoidConfig -ConfigPath $configPath -Agent $agent; $ok = Validate-JsonMemoidConfig -ConfigPath $configPath -Agent $agent }
            "opencode" { Ensure-JsonMemoidConfig -ConfigPath $configPath -Agent $agent; $ok = Validate-JsonMemoidConfig -ConfigPath $configPath -Agent $agent }
            "codex" { Ensure-CodexMemoidConfig -ConfigPath $configPath; $ok = Validate-CodexMemoidConfig -ConfigPath $configPath }
        }

        if (-not $ok) {
            throw "Failed to validate Memoid MCP config for $agent at $configPath"
        }

        Write-Success "Configured Memoid MCP for $agent at $configPath"
        $script:McpConfiguredAny = $true
    }
}

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

# 3. Clone
Write-Info "Cloning Memoid into $InstallPath..."
git clone $RepoUrl $InstallPath
Set-Location $InstallPath

# 4. Global CLI Setup (Adding to User Path)
Write-Info "Checking for scripts directory in PATH..."
$ScriptsDir = Join-Path $HOME "Documents\WindowsPowerShell\Scripts"
if (-not (Test-Path $ScriptsDir)) { New-Item -ItemType Directory -Path $ScriptsDir -Force }

$DestFile = Join-Path $ScriptsDir "memoid.ps1"
Copy-Item "scripts\memoid.ps1" $DestFile -Force
Write-Success "CLI 'memoid' installed to $DestFile"

Write-Info "Running CLI smoke test..."
& $DestFile version | Out-Null
Write-Success "CLI smoke test passed"

Write-Info "Initializing Memoid memory..."
& $DestFile init
Write-Success "Memoid memory initialized"

# 5. MCP Setup
Configure-DetectedMcpClients

if (-not $McpConfiguredAny) {
    Write-Host ""
    Write-Info "To set up Memoid as an MCP server for your AI agent, please refer to the instructions in the README.md"
}

Write-Success "`nMemoid installation complete!"
Write-Info "Path: $InstallPath"
Write-Info "You can now run 'memoid gemini' or use it via MCP in your configured agents."
