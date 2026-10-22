# Contributing

Thanks for helping improve VMSKURetirementReport. Contributions of all sizes are welcome: bug reports, Microsoft series
mappings, rule improvements, report UX and docs.

## Ground rules

1. **Evidence first.** Retirement status, dates and recommended replacement series must come from an official
   Microsoft source (Microsoft Learn lifecycle pages, migration guides, Azure Updates). Link it in the PR.
2. **Read-only forever.** The tool must never modify Azure resources. PRs that add write operations will be declined.
3. **Never guess.** If something cannot be verified, label it (`Unable to Verify`, `Unable to Confirm`) rather than
   inferring it.
4. **No real customer data.** Tests, fixtures, screenshots and issues must use synthetic data such as `Contoso`,
   `11111111-...` IDs and `*.example` domains. Never commit a real report folder, `run.log`, or a screenshot that shows real
   subscription, tenant, resource group or server names. The `Repository PII scan` workflow
   (`.github/workflows/repo-pii-scan.yml`) checks for secrets, personal e-mail addresses, tenant domains, real-looking GUIDs,
   local user paths, public IP addresses and report output files, and warns when an image is added. To run it locally, use
   `pwsh .github/scripts/Test-RepoPii.ps1` from the repository root. A justified exception goes into
   `.github/pii-allowlist.json` as an exact value with a reason.

## Development setup

The assessment runtime supports PowerShell 7.2 and later, 7.4 and later included, on Windows, through Azure CLI, as a
GitHub Copilot skill or as a standalone script; Linux, macOS and containers are not supported. Local lint and Pester
development use PowerShell 7.4+ because the locked Pester 6.2.0 and PSScriptAnalyzer 1.24.0 releases target .NET 8, so
the test suite cannot run on 7.2; CI checks 7.2 by running the complete mock assessment under it. The Azure CLI is only
needed for live runs; tests use a mock. Build dependencies are locked in `dependencies.psd1`; Bootstrap installs
only those exact versions and verifies a committed hash of each module's files before import. The hash covers the files
in ordinal path order and ignores installer metadata such as `PSGetModuleInfo.xml`, so it does not depend on the
culture-specific sort order or on the installer; on a mismatch the build prints the module's file manifest. To move to a new
tool version, change its `Version` in `dependencies.psd1`, run `./build.ps1 -Task Bootstrap` (it installs the version and
prints the manifest and the new hash because the old hash no longer matches), review the release, and commit the new
`TreeHash`. CI also runs the complete mock assessment under PowerShell 7.2.24 (the supported floor) and 7.4.21, installed
on a Windows runner from pinned, checksum-verified official archives; to move one of those versions, update the version
and SHA-256 in the `powershell-compat` job of `.github/workflows/vm-sku-retirement-report-ci.yml`. A second CI job rebuilds
the sample and fails when it differs from `examples/sample-report` (see **Report changes** below), and an informational job
runs the browser smoke test below in Edge.

```powershell
git clone https://github.com/AzaryaShaulov/VMSKURetirementReport.git
cd VMSKURetirementReport
./build.ps1                    # Bootstrap, Lint, Version, Test
./build.ps1 -Task Sample       # regenerate examples/sample-report (with --check-modernization)
./build.ps1 -Task SampleDiff   # check that the committed sample is what a fresh build writes; changes nothing
./build.ps1 -Task Package      # build dist/VMSKURetirementReport-v<version>.zip
./build.ps1 -Task Package -DistPath $env:TEMP\vmsku-package   # try a package without touching dist/
```

The HTML report has no scripts, so the collapsible VM details are plain CSS (a hidden checkbox and `:has()`), and the
Pester tests can only check the markup. After changing `templates/report.css` or the table/detail markup, run the
optional browser smoke test, which opens the sample in real engines (it needs Node.js and is not part of `build.ps1`; the
CI job restores the locked development dependency and uses the Edge that is on the runner):

```powershell
cd tools
npm ci --ignore-scripts --no-audit --no-fund
npx playwright-core install firefox webkit   # msedge/chrome use the installed browser
node browser-smoke.js ../examples/sample-report msedge firefox webkit
```

The smoke test covers index/subscription section visibility, navigation, compact headings, keyboard/click controls,
print rendering and overflow at desktop and phone widths. Update `tools/package.json` with npm and commit the matching
`tools/package-lock.json` when upgrading Playwright; do not update the workflow independently.

CI validates workflow syntax and action inputs with actionlint v1.7.12, downloaded from the official release and
checked against its pinned SHA-256 before execution. Run `.\.github\scripts\Test-Workflows.ps1` locally on Windows
to perform the same check (requires internet access). Configuration tests also reject remote actions without a full
commit SHA. CI and release uploads select only the current tool-version ZIP/checksum and fail if that pair is absent.

## Repository layout

| Path | Purpose |
|---|---|
| `skills/vm-sku-retirement-report/SKILL.md` | Agent skill definition (what agents read) |
| `skills/vm-sku-retirement-report/README.md` | Short README that ships in the folder and in the release ZIP (requirements, how to run, what is in the folder) |
| `skills/vm-sku-retirement-report/scripts/` | Orchestrator, catalog refresh and modules |
| `skills/vm-sku-retirement-report/data/` | Cached Microsoft evidence, series map, processor catalog, scoring weights |
| `skills/vm-sku-retirement-report/references/` | Methodology, scoring, output schema and data-source docs |
| `skills/vm-sku-retirement-report/tests/` | Pester unit + end-to-end tests with a mock Azure CLI (not packaged) |
| `tools/` | Development-only browser smoke test for the HTML report (not packaged) |
| `dist/` | Versioned customer ZIP packages and SHA-256 checksums |
| `examples/sample-report/` | Generated sample report (synthetic data) |

## Common changes

- **A new retired / End of Life series appears on Microsoft Learn.** Run `scripts/Update-Catalogs.ps1`. If it warns
  about an unmapped series, add its size-name pattern to `data/series-map.json` (from the Learn size page), add a
  classification test, and commit the refreshed catalogs. If a retired-list *section* lists things that are not VM sizes
  (for example `ADH` Dedicated Host SKUs), add the section name to `nonVmSizeCategories` instead of mapping it.
- **Scoring or rule changes.** Update `references/methodology.md` / `references/scoring.md` and add tests.
- **Report changes.** Keep all HTML values encoded through `ConvertTo-HtmlEncoded` and regenerate the sample. The sample
  build is offline and reproducible: it uses the cached catalog, `$script:SampleAsOfDate` in `build.ps1` and
  `tests/fixtures/retail-prices-eastus2.json`. After refreshing the catalog, bump the date and rebuild. Any change to the
  code, data or templates that alters the sample must be committed together with the regenerated sample: the CI job
  `sample-diff` (`./build.ps1 -Task SampleDiff`) fails otherwise, and prints the first differing line of each file.
- **Package changes.** The release ZIP holds the skill folder without `tests/`, plus the root `LICENSE`,
  `THIRD-PARTY-NOTICES.md` and `CHANGELOG.md`. `./build.ps1 -Task Package` compares the finished ZIP with the skill folder and
  fails on a missing or unexpected file, so a new file in the skill folder is packaged automatically.

## Pull requests

- Keep changes focused, and add or update tests.
- `./build.ps1` must pass. CI runs the same tasks on a Windows runner.
- Add an entry under **Unreleased** in `CHANGELOG.md`.

## Standalone repository setup (maintainers)

The standalone CI badge and editor configuration depend on the root-level `.github/` and `.vscode/` files being
committed and published with the project. After publishing the workflows to `main`, verify that
[VMSKURetirementReport CI](https://github.com/AzaryaShaulov/VMSKURetirementReport/actions/workflows/vm-sku-retirement-report-ci.yml)
is registered and the README badge reflects this repository, not the parent project.

Private vulnerability reporting requires a separate owner action; see [SECURITY.md](SECURITY.md#maintainer-setup).
Publishing an issue-template link does not enable the reporting form.

Keep released ZIPs and their checksums immutable. Link corrections in source, reference documents and the generated
sample ship in the next release; use `-DistPath` to validate an unpublished package without replacing a released ZIP.
Historical release links and cached Microsoft evidence may still point to their original sources and must not be
rewritten as part of an active-link cleanup.

### Codacy SARIF uploads

The Codacy workflow keeps the v4 uploader SHA-pinned. `.github/scripts/Split-CodacySarif.ps1` splits the CLI output into
one file per run and assigns unique `automationDetails.id` categories using the tool name and its occurrence number.
Keep repeated runs for a tool in a stable order so their code-scanning categories remain stable across scans.
Findings, rules and other run metadata are retained; the automation ID is deliberately replaced.

Only the upload step is temporarily non-blocking. An upload failure emits a warning and a job summary; a green workflow
alone does not prove code-scanning results were published. Check the upload step and the repository's code-scanning
analysis timestamps. CLI failures and invalid SARIF still fail the workflow. Remove `continue-on-error` and the warning
step once successful uploads have been verified on `main` and pull requests.

If a v4-specific regression remains, the rollback candidate is the previously used v3.39.0 commit
`ce5e7eeac396d720fe2d802714996c8ce561e311`. Do not downgrade alongside the v4 fix or assume a downgrade bypasses GitHub's
server-side validation. Verify acceptance before adopting that fallback; if adopted, temporarily ignore only the
`github/codeql-action/upload-sarif` v4 major bump in Dependabot, and remove that exception when restoring v4.

## Releasing (maintainers)

1. Bump `$script:ToolVersion` in `scripts/modules/Common.psm1` and `metadata.version` in `SKILL.md`.
2. Move the **Unreleased** notes into a new `## [x.y.z] - YYYY-MM-DD` section in `CHANGELOG.md`.
3. From the repository root, run `./build.ps1 -Task Version, Test, SampleDiff, Package`.
4. Verify and commit `dist/VMSKURetirementReport-vX.Y.Z.zip` and its `.zip.sha256` checksum so customers can download
   both files directly from the repository.
5. Tag `vm-sku-retirement-report-vX.Y.Z` and push the tag. The tag carries the project name so that a tag for another
   project never starts the release; the repository's Release workflow checks that it matches
   the tool version, requires the tagged commit to be reachable from `main`, and also publishes the same files as GitHub release assets.
   Repository owners should import `.github/rulesets/release-tag-protection.json` (Settings > Rules > Rulesets) so
   release tags cannot be deleted or moved. Use a SemVer pre-release suffix such as `1.2.3-c`, not `1.2.3c`.
