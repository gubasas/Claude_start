# Claude_start installer
# Installs /startnew globally and opens Claude Code to install the claude-code-setup plugin

$CommandsDir = "$HOME\.claude\commands"
$Source = Join-Path $PSScriptRoot "plugins\claude-start\skills\startnew\SKILL.md"

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

# Check if claude-code-setup plugin is already installed
$PluginInstalled = Get-ChildItem "$HOME\.claude\plugins\" -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -match "claude-code-setup" }

if ($PluginInstalled) {
    Write-Host "v claude-code-setup plugin already installed"
    Write-Host ""
    Write-Host "All done! Open any project folder in Claude Code and type /startnew"
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
