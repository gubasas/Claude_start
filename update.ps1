# Claude_start updater — pulls latest changes and refreshes the global command and hook cache

$CommandsDir = "$HOME\.claude\commands"
$HooksCache = "$HOME\.claude\claude-start\hooks"
$HooksSrc = Join-Path $PSScriptRoot "plugins\claude-start\hooks"
$ScriptDir = $PSScriptRoot

Write-Host ""
Write-Host "Claude_start updater"
Write-Host "--------------------"

# Pull latest
Set-Location $ScriptDir
git pull

# Refresh global commands
Copy-Item "plugins\claude-start\skills\startnew\SKILL.md" "$CommandsDir\startnew.md" -Force
Write-Host "v /startnew updated to latest version"

$StartupdateSrc = Join-Path $PSScriptRoot "plugins\claude-start\skills\startupdate\SKILL.md"
if (Test-Path $StartupdateSrc) {
    Copy-Item $StartupdateSrc "$CommandsDir\startupdate.md" -Force
    Write-Host "v /startupdate updated to latest version"
}

# Refresh hook cache — /startupdate reads from here to patch existing projects
New-Item -ItemType Directory -Force -Path $HooksCache | Out-Null
Copy-Item "$HooksSrc\memory-signal.sh" "$HooksCache\memory-signal.sh" -Force
Copy-Item "$HooksSrc\memory-consolidate.sh" "$HooksCache\memory-consolidate.sh" -Force
Copy-Item "$HooksSrc\memory-signal.ps1" "$HooksCache\memory-signal.ps1" -Force
Copy-Item "$HooksSrc\memory-consolidate.ps1" "$HooksCache\memory-consolidate.ps1" -Force
Write-Host "v Hook cache refreshed at ~/.claude/claude-start/hooks"
Write-Host ""
Write-Host "Run /startupdate in any existing project to apply the latest hooks."
Write-Host ""
