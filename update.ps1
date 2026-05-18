# Claude_start updater — pulls latest changes and refreshes the global command

$CommandsDir = "$HOME\.claude\commands"
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
Write-Host ""
