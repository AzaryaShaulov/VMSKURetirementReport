# Changelog

All notable changes to this project are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and the project uses [Semantic Versioning](https://semver.org/).
Only user-visible changes are listed; the full history is in the Git log.

## [Unreleased]

### Fixed

- The tenant index omits the cross-vendor warnings, SKU family reference, CPU-vendor naming guide and known
  limitations sections and their navigation links. Subscription pages retain them. Collapsible section headings
  use less vertical padding on desktop and mobile.
- Codacy SARIF output is split into single-run files with distinct automation categories for the v4 uploader,
  including when multiple runs use the same tool name or automation ID. Findings and rule metadata are preserved.
- SARIF upload failures are temporarily non-blocking, with an explicit warning and job summary. Analysis and SARIF
  preparation errors still fail the workflow; the pinned v4 uploader is retained rather than downgrading to v3.

## [1.2.3-c] - 2026-10-20

### Changed

- The Codacy workflow pins `actions/checkout` and `github/codeql-action/upload-sarif` to full commit SHAs, matching the
  other workflows.
- Version checks accept a SemVer pre-release suffix such as `1.2.3-c`.
- The release workflow requires the tagged commit to be reachable from `main`, and
  `.github/rulesets/release-tag-protection.json` provides an importable ruleset that blocks deletion and moves of
  release tags (it must be imported by a repository admin).
- External references rechecked: the GitHub commits link resolves; the two Intel reference URLs in the processor
  catalog return HTTP 403 to automated clients and could not be verified, so they were left unchanged.

### Fixed

- CI, release workflows, editor settings and Copilot instruction matching now use the standalone repository layout.
  CI runs for all pull requests and pushes to `main`.
- The PII scanner recognizes the root-level synthetic sample report, and its self-test uses the same layout.
- The default pull request template uses the root build command, and private vulnerability reports point to this repository.
  Contributor setup instructions now clone and build the standalone repository.
- Active installation, download, support, CI and report-source links now point to the standalone repository, with
  root-relative source-checkout commands. Historical release links and published packages are preserved.
- The unavailable design-attribution repository link now uses the author's project overview, and private-reporting
  guidance explicitly documents the required owner enablement instead of assuming the form is available.
- Remaining Windows source-checkout paths now use the standalone root, and migration regression checks recognize both
  path separators. Security reporting guidance no longer claims that the now-enabled private reporting form is disabled.
- Removed an obsolete PII-scan exception for an Azure Arc dashboard that was not migrated to this repository.

## [1.2.3] - 2026-10-17

The first release since 1.0.0. It includes everything listed for 1.1.0, 1.1.2 and 1.2.0 (never released separately).

### Changed

- **The report is called "Azure VM SKU Retirement Report".** The tool, its scripts, the ZIP and the `tool` field of
  `assessment.json` keep the name `VMSKURetirementReport`.
- **The retirement date is no longer shown in the HTML and Markdown reports.** It is still in `vm-assessment.csv` and
  `assessment.json` (`RetirementDate`, `TimeRemaining`, `ByRetirementDate`). The *Retirement target* column also no longer
  repeats the quota status; the quota status stays in the VM details and the quota table.
- **A more even VM details block, and a page 10% wider.** *Validate before resizing* now sits under *What to do*, beside
  *What changes*, and both columns end at the same height. The report's maximum width grew from 1480 to 1630 px.
- **A larger size of a series is now tried.** When the smallest fitting size fails a size-dependent check (NIC or data-disk
  limit, zone, restriction), the next sizes are evaluated (default 2 steps, `primarySelection.maxLargerSizeSteps`) and the
  first one that qualifies is offered as a *Larger size* variant with a validation item. Fewer VMs end up with no
  recommendation.
- **Rightsizing suggestions follow the migration checks** (NIC, disk and zone limits, no constrained-vCPU sizes) and are now
  repeatable; a VM with no memory headroom is `No Opportunity`.
- **Honest next steps and counts.** A `Ready` VM says `Validate Before Resize` unless confidence is `HIGH`. The estate
  summary adds counters for v6/v7 paths that need a conversion first and shows `not evaluated` when the modernization check
  did not run. The HTML counts modernization (Wave 4) the same way everywhere.
- **Azure Advisor items are no longer all called retirement signals.** Only items that name a VM size corroborate the
  lifecycle.
- **CI and releases run on Windows only.** Linux, macOS and containers are not supported. PowerShell 7.2 and later stay
  supported and are tested under 7.2.24 and 7.4.21. New jobs check that the committed sample is current and open the HTML in
  Edge. Releases start on tags named `vm-sku-retirement-report-vX.Y.Z`.
- **The release ZIP has no tests and includes a README** (26 files), with `CHANGELOG.md`, `LICENSE` and
  `THIRD-PARTY-NOTICES.md`. `npx skills add` still copies the skill folder as it is, including `tests/`.
- The Gen1 to Trusted launch rule was re-checked against Microsoft Learn, an unreported disk controller (SCSI assumed) is
  now stated where a conversion depends on it, and the HTML footer says "Report generated" with the number of warnings
  instead of "generated successfully".

### Fixed

- **CI could never pass.** The check of the locked Pester and PSScriptAnalyzer modules depended on the machine; it is now
  independent of culture and installer metadata.
- **Failed Azure reads were invisible.** A denied or unreadable Resource SKUs, quota, Advisor, Service Health, pricing or
  Azure Monitor call is now recorded once per subscription and region, with the reason and its effect, and shown in the
  console, `run.log`, `assessment.json` (`collectionIssues`), the executive summary and the HTML.
- **`run.log` and error text could hold the signed-in account and its object id.** Both are now masked, also after a REST
  failure.
- **Stale or incomplete retirement evidence** (a cache over 90 days old, or a live parse that lost series) now warns, and
  `Update-Catalogs.ps1` keeps the existing cache.
- **A CPU vendor inferred from the size name no longer leaves confidence at `HIGH`.** The processor catalog gained eight
  newer series.
- **An older-generation fallback target now gets a validation item**, and replacement sizes can no longer be taken from
  another VM's evaluation.
- **Stable output shapes.** Documented JSON arrays are always arrays, and the CSV files always contain the header row.
  `references/output-schema.md` now matches the output and is tested against it.
- A malformed answer from `az` no longer escapes `-AllowFailure`.

## [1.2.0] - 2026-10-12

### Changed

- **One table row and one collapsible detail block per VM.** The separate details section is gone. Each row has details
  directly under it with the move (current to retirement target, and to the modernization target with
  `--check-modernization`), badges, what to do, what changes, validation items and recommended sizes. An *Expand all* switch
  opens every block.
- The current size, retirement target and modernization target use the same layout (Vendor, vCPU, vRAM, VM Gen, Disk
  controller). The current Hyper-V generation and disk controller come from the VM itself.
- The v6/v7 modernization part is merged into this table; the separate band and tables were removed. One quota table shows
  steady-state and peak demand.
- Shorter cards, a slimmer Bottom line box, collapsed README options and a single badge legend.

### Added

- *Gen1 VMs* card, `-ExtendedDetails` (HTML), `strategy.TargetComparison` in `assessment.json`, and the CSV column
  `ModernizationMaterialDifferences` (appended; all earlier columns keep their position).
- `tools/browser-smoke.js`, an optional browser check of the HTML report.

## [1.1.2] - 2026-10-08

- Repository links in HTML footers and Markdown reports.
- Qualified the *Ready* and *HIGH* explanations: assessed checks do not guarantee hardware capacity.
- Incomplete Retail Prices pagination now discards that region's prices instead of using partial data.

## [1.1.0] - 2026-10-07

### Added

- Microsoft lifecycle stage per VM (`LifecycleStage`: Retired, End of Life, Not End of Life, Unknown).
- `-SaveSnapshot` / `-FromSnapshot` to record a run's Azure reads and replay them later with different options.
- Optional `--check-modernization`: v6/v7 targets with a migration path, guest validation items (NVMe, MANA, temp disk, Gen1
  Trusted launch), steady-state and peak quota planning, and Microsoft Learn guidance links.
- Retirement target and modernization target are separate fields in the CSV and JSON.

### Changed

- Retail PAYGO pricing is on by default.
- Renamed the project, skill, command, report branding and release artifacts to VMSKURetirementReport.
- Corrected quota accounting for same-family resizes and made the modernization fallback quota-aware.
- Pinned the Pester and PSScriptAnalyzer versions and the GitHub Actions to exact versions.

### Security

- CSV exports neutralize spreadsheet formulas (JSON keeps the raw data).
- Removed the PowerShell Gallery publisher-check bypass and added committed dependency integrity hashes.

## [1.0.0] - 2026-10-06

First public release.

- `vm-sku-retirement-report` agent skill (GitHub Copilot, Claude Code and other Agent Skills clients) that also runs
  directly from PowerShell 7.2+.
- **Retirement evidence** from Microsoft Learn, with provenance and a cached fallback. No retirement date is ever inferred.
- **Estate inventory** through Azure Resource Graph across all accessible subscriptions, with Advisor and Service Health
  signals as corroboration.
- **Replacement engine** that keeps the CPU vendor and architecture, recommends current-generation sizes only, never
  downsizes, follows Microsoft's target series, enforces mandatory gates and offers primary, alternative and third
  candidates, with a 0-100 score, HIGH/MEDIUM/LOW confidence and data-quality labels.
- Regional availability and restrictions, aggregated quota impact (with minimum and recommended increases), migration waves,
  optional Azure Monitor rightsizing (`-IncludeRightsizing`) and PAYGO pricing (`-IncludePricing`).
- **Outputs:** `assessment.json` (versioned schema), `vm-assessment.csv`, `candidates.csv`, `quota-impact.csv`,
  `retirement-evidence.json`, `executive-summary.md`, `detailed-report.md` and a responsive, script-free HTML report.
- **Privacy by default:** the signed-in account is masked unless `-IncludeOperatorAccount`, paths hide the home directory,
  and inventory queries never read admin usernames, computer names, IP addresses or tags.
- Read-only by design; `-TenantId` assesses any signed-in tenant without changing the Azure CLI default.
- `build.ps1`, an offline Pester suite with a mock Azure CLI, a reproducible sample report, CI and a tag-driven release
  workflow.

[Unreleased]: https://github.com/AzaryaShaulov/VMSKURetirementReport/commits/main
[1.2.3]: https://github.com/AzaryaShaulov/Azure/tree/main/Assessments/VMSKURetirementReport/dist/VMSKURetirementReport-v1.2.3.zip
[1.2.0]: https://github.com/AzaryaShaulov/Azure/tree/main/Assessments/VMSKURetirementReport/dist
[1.1.2]: https://github.com/AzaryaShaulov/Azure/tree/main/Assessments/VMSKURetirementReport/dist
[1.1.0]: https://github.com/AzaryaShaulov/Azure/tree/main/Assessments/VMSKURetirementReport/dist
[1.0.0]: https://github.com/AzaryaShaulov/Azure/tree/main/Assessments/VMSKURetirementReport/dist
- Configuration tests now follow the standard `.github/instructions/` location. CI validates workflows with
  checksum-verified actionlint and tests enforce full-SHA remote action references.
- CI and release uploads select the current version's package/checksum only, instead of including historical archives.
- Browser checks use a committed npm lockfile and cover index/subscription sections, navigation and compact heading
  spacing on desktop and mobile. Output contract tests check zero/one/multiple-VM JSON shapes and CSV consistency.
