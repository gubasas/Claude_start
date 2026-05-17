# Claude_start installer for Windows (PowerShell)
# Run with: .\install.ps1

$CommandsDir = "$HOME\.claude\commands"
$Source = Join-Path $PSScriptRoot "startnew.md"

Write-Host ""
Write-Host "Claude_start installer"
Write-Host "----------------------"

# Check Claude Code is installed
if (-not (Test-Path "$HOME\.claude")) {
    Write-Host "Error: ~/.claude not found. Make sure Claude Code is installed first."
    Write-Host "Download it at: https://claude.ai/code"
    exit 1
}

# Create commands dir if needed
New-Item -ItemType Directory -Force -Path $CommandsDir | Out-Null

# Copy the command file
Copy-Item $Source "$CommandsDir\startnew.md" -Force

Write-Host ""
Write-Host "Installed! Open any project folder in Claude Code and type /startnew"
Write-Host "On your first run, you'll be asked to choose your preferred command name."
Write-Host ""
