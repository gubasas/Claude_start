# Claude_start: memory signal detector (Stop hook)
# Detects decisions, preferences, bugs, constraints worth saving.

$HooksDir = $PSScriptRoot
$CounterFile = Join-Path $HooksDir ".ms_count"
$LastFireFile = Join-Path $HooksDir ".ms_last"

# Increment turn counter
$Count = 0
if (Test-Path $CounterFile) {
    try { $Count = [int](Get-Content $CounterFile -Raw).Trim() } catch {}
}
$Count++
Set-Content $CounterFile $Count

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

# Extract last 4 messages from transcript (JSONL format)
$Recent = ""
try {
    $lines = Get-Content $TranscriptPath -Encoding UTF8
    $messages = [System.Collections.Generic.List[object]]::new()
    foreach ($line in $lines) {
        $line = $line.Trim()
        if ($line) {
            try { $messages.Add(($line | ConvertFrom-Json)) } catch {}
        }
    }
    $last4 = $messages | Select-Object -Last 4
    foreach ($m in $last4) {
        $role = $m.role
        $content = $m.content
        if ($content -is [array]) {
            $content = ($content | Where-Object { $_.text } | ForEach-Object { $_.text }) -join " "
        }
        $contentStr = [string]$content
        if ($contentStr.Length -gt 600) { $contentStr = $contentStr.Substring(0, 600) }
        $Recent += "${role}: ${contentStr}`n"
    }
} catch {}

if (-not $Recent) {
    Write-Output "{}"
    exit 0
}

$Lower = $Recent.ToLower()

# Pattern A: trigger phrases
$Phrases = "worked|didn.t work|fixed|broken|broke it|finally|that did it|still broken|still doesn|let.s use|let.s go with|we should use|i.ll use|i prefer|actually use|switch to|instead of|stick with|i always|i never|i hate|i love|i want|i don.t want|make sure to|remember to|don.t forget|the issue was|turns out|the problem is|ah i see why|won.t work|needs to|has to|doesn.t support"

if ([regex]::IsMatch($Lower, "($Phrases)")) {
    $Last = 0
    if (Test-Path $LastFireFile) { try { $Last = [int](Get-Content $LastFireFile -Raw).Trim() } catch {} }
    if (($Count - $Last) -ge 5) {
        Set-Content $LastFireFile $Count
        $reason = "Memory signal detected. Review the last several exchanges (back to the most recent memory write, or the start of the session if none) for any decision made, preference stated, bug fixed, or constraint discovered. If yes, write a brief entry to the appropriate memory/ file and confirm with one line. Be factual and brief."
        Write-Output (@{decision="block"; reason=$reason} | ConvertTo-Json -Compress)
        exit 0
    }
}

# Pattern B: option selection (brief user reply after Claude presented options)
$patternB = '[0-9]+[.)]\s|[a-zA-Z][.)]\s|[Ww]ould you prefer|[Pp]ick one|[Oo]ptions are|[Cc]hoose one|[Ww]hich would'
$patternBullet = '(?m)^\s*[-–—*•]\s'
if ([regex]::IsMatch($Recent, $patternB) -or [regex]::IsMatch($Recent, $patternBullet)) {
    $lastUserLine = ($Recent -split "`n" | Where-Object { $_ -match '^user:' } | Select-Object -Last 1)
    $wordCount = if ($lastUserLine) { ($lastUserLine -split '\s+' | Where-Object { $_ }).Count } else { 0 }
    if ($wordCount -gt 0 -and $wordCount -lt 10) {
        $Last = 0
        if (Test-Path $LastFireFile) { try { $Last = [int](Get-Content $LastFireFile -Raw).Trim() } catch {} }
        if (($Count - $Last) -ge 5) {
            Set-Content $LastFireFile $Count
            $reason = "A decision appears to have been made from a set of options. Review the last several turns to find what options were presented and which was selected. Note what was chosen, what was rejected, and any reasoning given in a memory/ file, then confirm with one line."
            Write-Output (@{decision="block"; reason=$reason} | ConvertTo-Json -Compress)
            exit 0
        }
    }
}

Write-Output "{}"
exit 0
