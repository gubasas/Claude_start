# Claude_start installer — safe to re-run at any time to update to the latest version
# Installs /startnew and /startupdate globally, caches hook scripts, and checks the claude-code-setup plugin

$CommandsDir = "$HOME\.claude\commands"
$HooksCache = "$HOME\.claude\claude-start\hooks"
$Source = Join-Path $PSScriptRoot "plugins\claude-start\skills\startnew\SKILL.md"
$HooksSrc = Join-Path $PSScriptRoot "plugins\claude-start\hooks"

Write-Host ""
Write-Host "Claude_start installer"
Write-Host "----------------------"

# Check Claude Code is installed
if (-not (Get-Command claude -ErrorAction SilentlyContinue)) {
    Write-Host "Error: 'claude' command not found. Make sure Claude Code CLI is installed."
    Write-Host "Download it at: https://claude.ai/code"
    exit 1
}

if (-not (Test-Path "$HOME\.claude")) {
    Write-Host "Error: ~/.claude not found. Make sure Claude Code is installed first."
    exit 1
}

# Install the /startnew command
New-Item -ItemType Directory -Force -Path $CommandsDir | Out-Null
Copy-Item $Source "$CommandsDir\startnew.md" -Force
Write-Host "v /startnew command installed"

# Install the /startupdate command (if it exists)
$StartupdateSrc = Join-Path $PSScriptRoot "plugins\claude-start\skills\startupdate\SKILL.md"
if (Test-Path $StartupdateSrc) {
    Copy-Item $StartupdateSrc "$CommandsDir\startupdate.md" -Force
    Write-Host "v /startupdate command installed"
}

# Cache hook scripts so /startupdate can refresh existing projects
New-Item -ItemType Directory -Force -Path $HooksCache | Out-Null
Copy-Item "$HooksSrc\memory-signal.sh" "$HooksCache\memory-signal.sh" -Force
Copy-Item "$HooksSrc\memory-consolidate.sh" "$HooksCache\memory-consolidate.sh" -Force
Copy-Item "$HooksSrc\memory-signal.ps1" "$HooksCache\memory-signal.ps1" -Force
Copy-Item "$HooksSrc\memory-consolidate.ps1" "$HooksCache\memory-consolidate.ps1" -Force
Write-Host "v Hook scripts cached at ~/.claude/claude-start/hooks"
Write-Host "  -> Run /startupdate in any existing project to refresh its hooks."

# Check if claude-code-setup plugin is already installed
$PluginInstalled = Get-Content "$HOME\.claude\plugins\installed_plugins.json" -ErrorAction SilentlyContinue |
    Select-String -Pattern "claude-code-setup"

if ($PluginInstalled) {
    Write-Host "v claude-code-setup plugin already installed"
    Write-Host ""
    Write-Host "Installed. /startnew is now available in any Claude Code session (terminal, VS Code, or the Claude desktop app's Code mode)."
} else {
    Write-Host ""
    Write-Host "One more step: installing the claude-code-setup plugin."
    Write-Host "Claude Code is opening now -- run this command when it loads:"
    Write-Host ""
    Write-Host "  /plugin install claude-code-setup@claude-plugins-official"
    Write-Host ""
    Write-Host "Then type /exit and open your project in VS Code."
    Write-Host ""
    Read-Host "Press Enter to open Claude Code"
    claude
}
