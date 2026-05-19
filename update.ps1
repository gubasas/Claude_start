# Claude_start updater — pulls latest changes and refreshes the global command

$CommandsDir = "$HOME\.claude\commands"
$HooksCache = "$HOME\.claude\claude-start\hooks"
$ScriptDir = $PSScriptRoot

Write-Host ""
Write-Host "Claude_start updater"
Write-Host "--------------------"

# Pull latest
Set-Location $ScriptDir
git pull

# Refresh global command
Copy-Item "plugins\claude-start\skills\startnew\SKILL.md" "$CommandsDir\startnew.md" -Force
Write-Host "v /startnew updated to latest version"

# Cache hook scripts for future per-project updater
New-Item -ItemType Directory -Force -Path $HooksCache | Out-Null
Write-Host "v Hook cache refreshed at ~/.claude/claude-start/hooks"
Write-Host ""
Write-Host "Note: existing project hooks are NOT updated automatically."
Write-Host "      Per-project hook updates are tracked in OPEN_ISSUES.md."
Write-Host ""
