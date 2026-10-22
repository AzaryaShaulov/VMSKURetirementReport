[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$root = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$temp = Join-Path ([IO.Path]::GetTempPath()) ("vmsku-actionlint-" + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $temp | Out-Null
try {
    $zip = Join-Path $temp 'actionlint.zip'
    Invoke-WebRequest -Uri 'https://github.com/rhysd/actionlint/releases/download/v1.7.12/actionlint_1.7.12_windows_amd64.zip' -OutFile $zip
    $expected = '6e7241b51e6817ea6a047693d8e6fed13b31819c9a0dd6c5a726e1592d22f6e9'
    if ((Get-FileHash -LiteralPath $zip -Algorithm SHA256).Hash.ToLowerInvariant() -ne $expected) {
        throw 'actionlint v1.7.12 archive failed SHA-256 verification.'
    }
    Expand-Archive -LiteralPath $zip -DestinationPath $temp
    $workflows = @(Get-ChildItem (Join-Path $root '.github/workflows') -File |
        Where-Object Extension -in '.yml', '.yaml' | ForEach-Object FullName)
    if (-not $workflows.Count) { throw 'No workflow files found.' }
    & (Join-Path $temp 'actionlint.exe') @workflows
    if ($LASTEXITCODE -ne 0) { throw "Workflow validation failed (actionlint exit $LASTEXITCODE)." }
    Write-Host "actionlint: $($workflows.Count) workflow(s) passed."
}
finally {
    # Windows may briefly retain an executable handle after the process exits.
    for ($attempt = 1; $attempt -le 3; $attempt++) {
        try {
            Remove-Item -LiteralPath $temp -Recurse -Force
            break
        }
        catch [System.UnauthorizedAccessException], [System.IO.IOException] {
            if ($attempt -eq 3) { throw }
            Start-Sleep -Seconds 1
        }
    }
}
