# Security Policy

## Supported versions

Security fixes are released for the latest minor version only.

| Version | Supported |
|---|---|
| 1.2.x | Yes |
| < 1.2 | No |

## Reporting a vulnerability

**Do not open a public issue for security problems.**

When enabled, use this repository's
[private vulnerability reporting form](https://github.com/AzaryaShaulov/VMSKURetirementReport/security/advisories/new)
(**Security** tab > **Report a vulnerability**).

**Private vulnerability reporting is not enabled yet for this standalone repository.** Until a maintainer enables and
verifies it, the form is unavailable. Do not submit vulnerability details through public issues or the bug-report form.
There is no verified alternative private reporting channel documented here.

Please include:

- the affected version (report footer, or `toolVersion` in `assessment.json`);
- steps to reproduce, using sanitized data;
- the impact you observed or expect.

You should receive an acknowledgement within 5 business days. Coordinated disclosure timelines are agreed case by case.

### Maintainer setup

A repository owner must enable private vulnerability reporting in **Settings > Security > Code security**, then verify
the reporting form while signed in. Follow GitHub's
[enablement instructions](https://docs.github.com/en/code-security/security-advisories/working-with-repository-security-advisories/configuring-private-vulnerability-reporting-for-a-repository).
Remove the unavailable notice above only after verification. Changing the URL alone does not enable reporting.

## Security design

- **Read-only.** The assessment only calls read APIs: Azure Resource Graph, Compute Resource SKUs, compute usage,
  Azure Monitor metrics and the public Retail Prices API. It never creates, modifies or deletes Azure resources.
- **No credential handling.** Authentication is delegated entirely to the Azure CLI (`az login`). The scripts never
  read, store or print tokens. Access tokens obtained from `az account get-access-token` are held in memory only for
  the REST calls that need them.
- **Least privilege.** The **Reader** role is sufficient; **Monitoring Reader** is needed only for `-IncludeRightsizing`.
- **Outbound calls** go only to `management.azure.com`, `<region>.metrics.monitor.azure.com`, `prices.azure.com`,
  `learn.microsoft.com`, and, for catalog maintenance only, `api.github.com` / `raw.githubusercontent.com`.
- **Output sensitivity.** Reports contain tenant, subscription, resource group and VM identifiers. Store them like any
  other inventory data. The repository `.gitignore` excludes assessment outputs by default.
- **Personal data minimization.** Inventory queries never read admin usernames, computer names, IP addresses or tags.
  The operator's account is masked in the console, `run.log` and `assessment.json` unless `-IncludeOperatorAccount` is
  passed; the transcript uses a minimal header (no local user, machine or command line); displayed paths show the home
  directory as `~`; Azure CLI error text is sanitized (emails and the identity's object id masked, home path hidden, length
  capped); `run.log` is checked again after the run, because PowerShell writes a caught REST error to the transcript before
  the report can sanitize it; and raw inventory dumps are written only with `-KeepRawData`. `-SaveSnapshot` stores raw Azure
  read responses (never access tokens; the signed-in account is masked) so a run can be replayed offline with
  `-FromSnapshot`; treat the snapshot as confidential inventory data.
- **HTML safety.** All values written to HTML reports are HTML-encoded. Reports contain no scripts and load no remote
  assets.
