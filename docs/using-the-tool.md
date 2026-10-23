# Using the Azure VM SKU Retirement Report

This guide covers installation, common commands, generated files, and result interpretation. For the short path from
download to report, start with the root [README](../README.md). For questions about retirement policy and specific
scenarios, see the [FAQ](faq.md).

## Requirements and permissions

- Windows and PowerShell 7.2 or later. Linux, macOS, containers, and Azure Cloud Shell are not supported.
- Azure CLI 2.60 or later with the Resource Graph extension.
- Reader access to each subscription being assessed. `-IncludeRightsizing` also requires Monitoring Reader.
- Network access to Azure management endpoints and Microsoft Learn. `-OfflineCatalog` uses the bundled lifecycle
  evidence instead.

The assessment reads inventory, regional SKU availability and restrictions, quota, and optionally metrics and public
retail prices. It does not modify Azure resources or submit quota requests. `az login` may update the local Azure CLI
sign-in cache. Do not automate or handle user credentials.

## Install and run the release

The current version is **1.2.3-c**. Download both the ZIP and its SHA-256 file from
[`dist/`](../dist/). In PowerShell, verify the package before extracting it:

```powershell
$version = '1.2.3-c'
$base = "https://raw.githubusercontent.com/AzaryaShaulov/VMSKURetirementReport/main/dist/VMSKURetirementReport-v$version"
Set-Location (Join-Path $HOME 'Downloads')
Invoke-WebRequest "${base}.zip" -OutFile "VMSKURetirementReport-v$version.zip"
Invoke-WebRequest "${base}.zip.sha256" -OutFile "VMSKURetirementReport-v$version.zip.sha256"

$actual = (Get-FileHash ".\VMSKURetirementReport-v$version.zip" -Algorithm SHA256).Hash.ToLowerInvariant()
$expected = (Get-Content ".\VMSKURetirementReport-v$version.zip.sha256").Split()[0]
if ($actual -ne $expected) { throw 'Package checksum verification failed. Do not extract or run the ZIP.' }

Unblock-File ".\VMSKURetirementReport-v$version.zip"
Expand-Archive ".\VMSKURetirementReport-v$version.zip" -DestinationPath 'C:\Tools\VMSKURetirementReport' -Force
```

Unblock the verified ZIP before extracting it. If you already extracted it with Windows Explorer and PowerShell blocks
the unsigned scripts, unblock the extracted files instead:

```powershell
Get-ChildItem 'C:\Tools\VMSKURetirementReport' -Recurse -File | Unblock-File
```

Do not change the machine-wide execution policy to work around blocked files. Sign in, install the extension, run the
assessment, and open the HTML report:

```powershell
az login --tenant '<tenant-id>'
az extension add --name resource-graph
az account show --output table

$script = 'C:\Tools\VMSKURetirementReport\vm-sku-retirement-report\scripts\Invoke-VMSKURetirementReport.ps1'
& $script -OutputPath 'C:\Reports\vm-sku\assessment'
Invoke-Item 'C:\Reports\vm-sku\assessment\index.html'
```

Replace `<tenant-id>` with the intended tenant ID. Omit `-TenantId`, `-SubscriptionId`, and `-Region` to assess every
enabled subscription readable in the signed-in tenant. `-OutputPath` must be a new or empty directory; use a different
directory for each run.

### Run from a source checkout

After cloning this repository, run the same script from the repository root:

```powershell
git clone https://github.com/AzaryaShaulov/VMSKURetirementReport.git
Set-Location .\VMSKURetirementReport
$script = '.\skills\vm-sku-retirement-report\scripts\Invoke-VMSKURetirementReport.ps1'
.\skills\vm-sku-retirement-report\scripts\Invoke-VMSKURetirementReport.ps1 `
  -OutputPath 'C:\Reports\vm-sku\assessment'
```

Use the `$script` variable above in the option examples below.

## Common options

### Scope an assessment

Pass one or more subscription IDs and regions to limit the scope:

```powershell
& $script `
  -SubscriptionId '11111111-1111-1111-1111-111111111111','33333333-3333-3333-3333-333333333333' `
  -Region eastus2,westus3 `
  -OutputPath 'C:\Reports\vm-sku\scoped-assessment'
```

To assess another signed-in tenant without changing the Azure CLI default subscription, add
`-TenantId '<tenant-id>'`.

### Check optional modernization

The standard assessment prioritizes announced retirement work. Add `--check-modernization` to evaluate every VM for a
possible same-architecture v7/v6 modernization path as well:

```powershell
& $script --check-modernization -OutputPath 'C:\Reports\vm-sku\modernization'
```

Modernization is optional and is not an announced retirement. Targets may require a conversion or additional guest
validation. Read the recommended path and validation items before planning a change.

### Reuse a snapshot

Save collected Azure data during an assessment, then replay it later with different report options:

```powershell
& $script -SaveSnapshot -OutputPath 'C:\Reports\vm-sku\capture'
& $script -FromSnapshot 'C:\Reports\vm-sku\capture' `
  --check-modernization -SkipPricing `
  -OutputPath 'C:\Reports\vm-sku\replay'
```

Replay uses captured inventory, quota, availability, scope, as-of date, and retirement evidence. It does not query Azure
inventory or management APIs; retail prices may still be retrieved online unless `-SkipPricing` is used. A warning
appears when a snapshot is over seven days old. Availability and quota can change, so capture fresh data before acting.
Snapshots contain a copy of estate inventory; protect them like reports.

### Other useful switches

| Option | Default | Use |
|---|---|---|
| `-OfflineCatalog` | Off | Use bundled Microsoft lifecycle evidence instead of fetching Learn pages. |
| `-SkipPricing` | Off | Skip informational public PAYGO prices; pricing is on by default. |
| `-IncludeRightsizing` | Off | Add a separate Azure Monitor utilization signal; it does not change the migration recommendation. Requires Monitoring Reader. |
| `-RightsizingLookbackDays <7-93>` | `30` | Choose the telemetry window when rightsizing is enabled. |
| `-HorizonMonths <12-120>` | `36` | Set the retirement planning horizon. |
| `-MaxCandidates <1-3>` | `3` | Limit how many ranked replacement choices are reported per VM. |
| `-QuotaSafetyPct <0-200>` | `20` | Add headroom to a recommended quota increase; it does not change whether quota currently fits. |
| `-KeepRawData` | Off | Save raw inventory and SKU responses under the output directory. Treat them as sensitive. |
| `-IncludeOperatorAccount` | Off | Include the full signed-in account in report metadata and logs instead of the default masked account. |
| `-HtmlIncludeOptionalModernization` | Off | Include optional-modernization VMs in HTML tables. |
| `-HtmlMaxVmDetails <count>` | `250` | Limit collapsible detail panels per subscription (`0` means no limit); all VMs remain in summary tables and exports. |
| `-ExtendedDetails` | Off | Include gate results and every evaluated size in HTML detail panels. |

For every parameter, accepted values, and snapshot behavior, see the entry-point script help:

```powershell
Get-Help $script -Full
```

## Read the results

Start with `index.html` or `executive-summary.md` for the estate-level findings and migration waves. Open a subscription
HTML page or `detailed-report.md` for VM-specific details. Use `vm-assessment.csv` to filter or analyze all VM rows, and
`quota-impact.csv` to review aggregated demand.

Each subscription page's **Retired and retiring VM sizes** KPI cards group VMs by current SKU and lifecycle status, and
show the VM count per SKU. They include only `Already Retired`, `Confirmed Retirement`, and `Retirement Announced`;
modernization-only or unconfirmed entries are excluded.

| Result | Meaning |
|---|---|
| **Retired / Confirmed Retirement** | Microsoft lifecycle evidence indicates that the size is retired or has an announced retirement. Review the source and planned date in the evidence and CSV/JSON. |
| **Modernization Optional** | An older generation may have a newer alternative, but this is not a retirement deadline. |
| **Unable to Confirm / Unable to Verify** | Evidence or required platform data is incomplete. Treat it as a manual review, not as proof that a size is current or available. |
| **Ready** | Observable compatibility, availability, and quota checks passed. This does not guarantee physical capacity or a successful resize. |
| **Quota Increase Required** | The calculated target demand exceeds available quota. The report estimates a request; it does not submit one. |
| **HIGH / MEDIUM / LOW confidence** | Confidence in the available assessment evidence, not a guarantee that the change will work. Follow each VM's validation items. |

Before any production change, validate the actual workload, licensing, storage and networking behavior, target availability,
quota, maintenance requirements, and the linked Microsoft documentation.

## Output files

All files are written to the selected output directory. Reports include identifiers and resource names and should be
handled as confidential inventory data.

| File | Purpose |
|---|---|
| `index.html` and `<subscription>-<id>.html` | Browsable estate and subscription reports. Each subscription page has KPI cards for retired and retirement-announced VM counts by current SKU, then VM details for items requiring action. |
| `executive-summary.md` | Estate counts, migration waves, and quota actions. |
| `detailed-report.md` | Per-VM evidence, recommendation, comparison, and validation items. |
| `vm-assessment.csv` | One row per VM, suitable for Excel or Power BI. |
| `candidates.csv` | Evaluated replacement sizes, scores, and rejection reasons. |
| `quota-impact.csv` | Aggregated family and regional quota demand, by assessment scope. |
| `assessment.json` | Complete versioned assessment; see the [output schema](../skills/vm-sku-retirement-report/references/output-schema.md). |
| `retirement-evidence.json` | Microsoft lifecycle evidence and provenance, with available corroborating signals. |
| `run.log` | Run transcript; account is masked by default. |
| `data/`, `snapshot/` | Optional raw data or saved Azure responses; especially sensitive. |

CSV, JSON, and Markdown include every VM. HTML defaults to VMs with an announced retirement and required action. Prices
are informational public PAYGO estimates; they do not include enterprise discounts, reservations, savings plans, or
Azure Hybrid Benefit.

## How the assessment works

1. Establish tenant and subscription scope from the Azure CLI sign-in.
2. Read lifecycle evidence from Microsoft Learn (or the bundled catalog) and inventory VMs and related resources through
   Azure Resource Graph.
3. Classify lifecycle status, keeping announced retirement separate from optional modernization.
4. Evaluate regional SKU choices against architecture, CPU-vendor preference, generation, size, and workload
   compatibility requirements.
5. Aggregate family and regional vCPU demand, then label readiness, confidence, action, and migration wave.
6. Write HTML, Markdown, CSV, JSON, and evidence files.

See the full [methodology](../skills/vm-sku-retirement-report/references/methodology.md),
[scoring rules](../skills/vm-sku-retirement-report/references/scoring.md), and
[data sources and permissions](../skills/vm-sku-retirement-report/references/data-sources.md).

## Limitations and support

- The control plane cannot confirm physical regional capacity; `Quota OK` does not guarantee allocation.
- Nested virtualization use, actual temporary-disk use, and network bandwidth caps are not fully observable.
- VM Scale Sets (Uniform) are not inventoried. Reserved Instance and Savings Plan coverage is not assessed.
- Retail prices do not include negotiated discounts or customer-specific benefits.
- Assessment results are informational; validate findings against current Microsoft documentation and workload needs.

For common questions, see the [FAQ](faq.md). For support and security issues, use [SUPPORT.md](../SUPPORT.md) and
[SECURITY.md](../SECURITY.md). For contributing, tests, packaging, and sample regeneration, see
[CONTRIBUTING.md](../CONTRIBUTING.md).
