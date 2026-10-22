[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$InputPath,
    [Parameter(Mandatory)][string]$OutputDirectory
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$log = Get-Content -LiteralPath $InputPath -Raw | ConvertFrom-Json -AsHashtable
if ($log -isnot [System.Collections.IDictionary] -or $log['version'] -ne '2.1.0' -or
    -not $log['runs'] -or $log['runs'] -isnot [array]) {
    throw 'Expected a SARIF 2.1.0 log with a non-empty runs array.'
}
foreach ($run in $log.runs) {
    if ($run -isnot [System.Collections.IDictionary] -or
        $run['tool'] -isnot [System.Collections.IDictionary] -or
        $run.tool['driver'] -isnot [System.Collections.IDictionary] -or
        [string]::IsNullOrWhiteSpace($run.tool.driver['name']) -or $run.tool.driver['name'] -isnot [string]) {
        throw 'Every SARIF run must have a tool.driver.name.'
    }
}
if (Test-Path -LiteralPath $OutputDirectory) {
    throw "Output directory already exists: $OutputDirectory. Use a fresh directory to avoid uploading stale runs."
}

New-Item -ItemType Directory -Path $OutputDirectory | Out-Null
$occurrences = [System.Collections.Generic.Dictionary[string, int]]::new([System.StringComparer]::Ordinal)
$index = 0
foreach ($run in $log.runs) {
    $name = $run.tool.driver.name
    if (-not $occurrences.ContainsKey($name)) { $occurrences[$name] = 0 }
    $occurrences[$name]++
    # Existing automation IDs may collide; per-tool ordinals keep repeated runs distinct.
    if (-not $run['automationDetails']) { $run.automationDetails = @{} }
    $run.automationDetails.id = "codacy/$([Uri]::EscapeDataString($name))/$($occurrences[$name])/"
    $single = $log.Clone()
    $single.runs = @($run)
    $path = Join-Path $OutputDirectory ("run-{0:D4}.sarif" -f $index++)
    $single | ConvertTo-Json -Depth 100 | Set-Content -LiteralPath $path -Encoding utf8NoBOM
}
Write-Host "Prepared $index SARIF run(s) with distinct automation categories."
