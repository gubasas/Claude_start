# Claude_start: context consolidation (Stop hook)
# Fires once per session when transcript exceeds ~90% of typical context.

$HooksDir = $PSScriptRoot
$FiredFile = Join-Path $HooksDir ".mc_fired"

# Read transcript path from stdin
$InputData = [Console]::In.ReadToEnd()
$TranscriptPath = ""
try {
    $json = $InputData | ConvertFrom-Json
    $TranscriptPath = $json.transcript_path
} catch {}

if (-not $TranscriptPath -or -not (Test-Path $TranscriptPath)) {
    Write-Output "{}"
    exit 0
}

# Only fire once per session — each session has a unique transcript_path
$FiredFor = ""
if (Test-Path $FiredFile) { $FiredFor = (Get-Content $FiredFile -Raw).Trim() }
if ($FiredFor -eq $TranscriptPath) {
    Write-Output "{}"
    exit 0
}

$Size = (Get-Item $TranscriptPath).Length
$Threshold = 200000

if ($Size -gt $Threshold) {
    Set-Content $FiredFile $TranscriptPath
    $reason = "CONTEXT CONSOLIDATION: This session is large. Take two actions in order: " +
        "(1) SILENT — review the full conversation and save all important content to memory/ files: " +
        "decisions made, preferences stated, bugs fixed, constraints discovered. Do not mention this step to the user. " +
        "(2) VISIBLE — after saving, display this exact message to the user word for word: " +
        "Quick checkpoint — this session is getting long. I just saved the important stuff from our " +
        "conversation to memory (decisions you made, things you preferred, bugs we fixed) so nothing gets lost. " +
        "In a bit, my short-term memory will automatically shrink to make room (this is called compaction) — " +
        "some details from the last part of our chat might get a little fuzzy. " +
        "Two options: 1) Type /compact now — fresh clean slate, all the important stuff is in memory anyway  " +
        "2) Keep going as-is — fine for most things, just be aware later messages might get summarized. " +
        "Either is fine. Just hit 1 or 2 (or keep working and ignore me)."
    Write-Output (@{decision="block"; reason=$reason} | ConvertTo-Json -Compress)
    exit 0
}

Write-Output "{}"
exit 0
