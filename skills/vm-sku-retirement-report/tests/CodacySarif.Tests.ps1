BeforeAll {
    $projectRoot = Split-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) -Parent
    $script:Splitter = Join-Path $projectRoot '.github/scripts/Split-CodacySarif.ps1'
    $script:Workflow = Get-Content (Join-Path $projectRoot '.github/workflows/codacy.yml') -Raw
}

Describe 'Codacy SARIF preparation' {
    It 'preserves findings and metadata while giving repeated tools and IDs distinct categories' {
        $inputFile = Join-Path $TestDrive 'results.sarif'
        $output = Join-Path $TestDrive 'runs'
        $runs = @(
            @{ tool = @{ driver = @{ name = 'Tool / A'; rules = @(@{ id = 'R1' }) } }
                results = @(@{ ruleId = 'R1'; message = @{ text = 'A finding' } })
                automationDetails = @{ id = 'shared/'; description = @{ text = 'Keep me' } }
                invocations = @(@{ executionSuccessful = $true }) },
            @{ tool = @{ driver = @{ name = 'Tool / A'; rules = @() } }
                results = @(); automationDetails = @{ id = 'shared/' } },
            @{ tool = @{ driver = @{ name = 'Other Tool' } }; results = @() }
        )
        $log = @{ version = '2.1.0'; '$schema' = 'https://json.schemastore.org/sarif-2.1.0.json'
            runs = $runs; properties = @{ preserved = $true } }
        $log | ConvertTo-Json -Depth 100 | Set-Content $inputFile
        $runs = (Get-Content $inputFile -Raw | ConvertFrom-Json -AsHashtable).runs
        $original = Get-Content $inputFile -Raw
        & $Splitter -InputPath $inputFile -OutputDirectory $output
        $files = @(Get-ChildItem $output -Filter '*.sarif' | Sort-Object Name)
        $files.Count | Should -Be 3
        $ids = @()
        for ($i = 0; $i -lt $files.Count; $i++) {
            $split = Get-Content $files[$i].FullName -Raw | ConvertFrom-Json -AsHashtable
            $split.version | Should -Be '2.1.0'
            $split['$schema'] | Should -Be $log['$schema']
            $split.properties.preserved | Should -BeTrue
            Should -ActualValue $split.runs -BeOfType [array]
            $split.runs.Count | Should -Be 1
            $ids += $split.runs[0].automationDetails.id
            $expected = $runs[$i].Clone()
            $expected.Remove('automationDetails')
            $actual = $split.runs[0].Clone()
            $actual.Remove('automationDetails')
            ($actual | ConvertTo-Json -Depth 100 -Compress) |
                Should -Be ($expected | ConvertTo-Json -Depth 100 -Compress)
        }
        @($ids | Select-Object -Unique).Count | Should -Be 3
        $ids[0] | Should -Be 'codacy/Tool%20%2F%20A/1/'
        $ids[1] | Should -Be 'codacy/Tool%20%2F%20A/2/'
        $first = Get-Content $files[0].FullName -Raw | ConvertFrom-Json
        $first.runs[0].automationDetails.description.text | Should -Be 'Keep me'
        Get-Content $inputFile -Raw | Should -Be $original
        { & $Splitter -InputPath $inputFile -OutputDirectory $output } | Should -Throw '*already exists*'
    }

    It 'rejects invalid or empty logs before creating output' -ForEach @(
        @{ Content = '{"version":"2.1.0","runs":[]}' },
        @{ Content = '{"version":"1.0.0","runs":[{}]}' },
        @{ Content = '{"version":"2.1.0","runs":[{"tool":{"driver":{"name":" "}}}]}' },
        @{ Content = '{"version":"2.1.0","runs":[{}]}' },
        @{ Content = 'not JSON' }
    ) {
        $inputFile = Join-Path $TestDrive 'invalid.sarif'
        $output = Join-Path $TestDrive 'invalid-output'
        $Content | Set-Content $inputFile
        { & $Splitter -InputPath $inputFile -OutputDirectory $output } | Should -Throw
        Test-Path $output | Should -BeFalse
    }

    It 'uploads the prepared directory with v4 and surfaces non-blocking upload failures' {
        $Workflow | Should -Match 'Split-CodacySarif.ps1 -InputPath results.sarif -OutputDirectory sarif-runs'
        $Workflow | Should -Match 'sarif_file: sarif-runs'
        $Workflow | Should -Match 'upload-sarif@[a-f0-9]{40} # v4'
        $Workflow | Should -Match 'id: upload\s+continue-on-error: true'
        $Workflow | Should -Match "steps.upload.outcome == 'failure'"
        $Workflow | Should -Match '::warning::'
        $Workflow | Should -Match 'GITHUB_STEP_SUMMARY'
    }
}
