# Claude_start installer — fallback for users who prefer git clone over /plugin install
# Usage: .\install.ps1

$CommandsDir = "$HOME\.claude\commands"
$Source = Join-Path $PSScriptRoot "plugins\claude-start\skills\startnew\SKILL.md"

Write-Host ""
Write-Host "Claude_start installer"
Write-Host "----------------------"

if (-not (Test-Path "$HOME\.claude")) {
    Write-Host "Error: ~/.claude not found. Make sure Claude Code is installed first."
    Write-Host "Download it at: https://claude.ai/code"
    exit 1
}

New-Item -ItemType Directory -Force -Path $CommandsDir | Out-Null
Copy-Item $Source "$CommandsDir\startnew.md" -Force

Write-Host ""
Write-Host "Installed! Open any project folder in Claude Code and type /startnew"
Write-Host ""
Write-Host "Tip: for full automation recommendations, also run:"
Write-Host "  /plugin install claude-code-setup@claude-plugins-official"
Write-Host ""
