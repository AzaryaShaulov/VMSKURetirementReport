# VM SKU Retirement Tool: Frequently Asked Questions

**Sources checked October 21, 2026**

Commercial clarification and selected retirement guidance reviewed November 2, 2026; other topics retain their review dates below.

For Azure administrators, architects, infrastructure teams, and IT decision-makers.

> **RI coverage and net cost: Not assessed**. This tool does not inspect reservation matching, expiration, utilization or your contracted bill. Public PAYGO estimates do not establish your net cost. Authorized billing exports are a possible later enhancement, not a current capability.

> **A quota restriction is not a VM shutdown notice.** End of Life means retirement has been announced, not that a VM is already retired. Capacity growth restrictions limit deployments or expansion; these controls do not affect existing running VMs. Actual retirement is a separate event: remaining affected VMs are deallocated and stop working at the retirement date. Check the applicable series, date, and cloud before deciding what action is required. [Lifecycle overview][lifecycle] | [Retirements and capacity restrictions][retirements]

## On this page

- [Lifecycle and retirement](#1-lifecycle-and-retirement)
- [Reserved Instances](#2-reserved-instances)
- [Azure savings plan for compute](#3-azure-savings-plan-for-compute)
- [Modernization compatibility](#4-modernization-compatibility)
- [Quota, availability, and capacity](#5-quota-availability-and-capacity)
- [Migration, downtime, and rollback](#6-migration-downtime-and-rollback)
- [Assessment and planning](#7-assessment-and-planning)
- [Understanding this tool](#8-understanding-this-tool)
- [Planning ahead for retirement](#9-planning-ahead-for-retirement)
- [Retirement and RI eligibility](#retirement-and-ri-eligibility)
- [Service Health notice register](#service-health-notice-register)
- [Sources and scope](#sources-and-scope)

## 1. Lifecycle and retirement

<details>
<summary>Q1. What do End of Life, capacity restrictions, and retirement mean?</summary>

| Term | Meaning | Customer impact |
| --- | --- | --- |
| End of Life | Retirement has been announced for the series. | The series is not retired yet and remains supported until its retirement date, subject to applicable restrictions. Plan and complete migration before that date. |
| Capacity growth restriction | A separate limit on new deployments, additional quota, or expansion for an affected series. | It does not itself stop existing running VMs. Deployment and recovery operations that need allocation can still be capacity-constrained. |
| Retired | The series has reached retirement. | It can no longer be used to create, resize into, or run VMs. Remaining VMs are deallocated, stop working, and no longer have an SLA or support. |

Current and Extended are also lifecycle stages. Both are fully supported; an older generation is not automatically End of Life. [Lifecycle overview][lifecycle] | [End of Life series][eol]

</details>

<details>
<summary>Q2. A quota increase is unavailable. Does that mean my VM will shut down now?</summary>

**No.** For series covered by the capacity growth restrictions, existing running VMs are not affected by the controls. Existing subscriptions can continue deploying and redeploying within already-approved quota, subject to available capacity. New subscriptions cannot deploy the affected series, and additional quota is not approved.

These restrictions are not a retirement announcement or an immediate shutdown instruction. Check the separate retirement date. Requests submitted before enforcement continue through the normal review process; approval is not promised. [Capacity restrictions and FAQ][retirements]

</details>

<details>
<summary>Q3. Which series are retiring, and when?</summary>

Use the current retirement list for the exact series and cloud. Selected examples, not a complete list:

| Series | Published retirement date |
| --- | --- |
| D, Ds, Dv2, Dsv2, Ls | May 1, 2028 |
| Av2/Amv2, B-series v1, F, Fs, Fsv2, G, Gs, Lsv2 | November 15, 2028 |
| Dv3, Dsv3, Ev3, Esv3 | November 15, 2029 |

The Dv3/Dsv3/Ev3/Esv3 announcement covers all 32 sizes in those four series. **That retirement announcement** does not apply to Azure Government, Azure operated by 21Vianet, or sovereign cloud regions. Do not extend this exclusion to other announcements without checking their scope.

Capacity growth restrictions beginning in July 2026 and RI purchase restrictions effective July 1, 2026 are separate events, not earlier VM retirement dates. [Retirement list][retirements] | [Modernization FAQ][modernization-faq]

</details>

<details>
<summary>Q4. What happens if a VM is still on a retired size at the deadline?</summary>

At retirement, remaining VMs in the affected series are deallocated and stop working; the retired size no longer has an SLA or support. In-memory and temporary-disk data is lost, while managed-disk data is preserved. Recovery on a supported size depends on compatibility and capacity; it is not a substitute for completing migration beforehand.

The end of VM compute usage does not establish that all associated disks, networking resources, or commercial commitments become free or are canceled. Review those separately. [Lifecycle overview][lifecycle] | [Retired sizes modernization guide][modernization-guide]

</details>

<details>
<summary>Q5. Can existing End of Life VMs keep running until retirement?</summary>

For Dv3, Dsv3, Ev3, and Esv3, existing VMs keep running and remain supported until November 15, 2029. Capacity growth restrictions do not themselves stop them.

Do not interpret this as guaranteed capacity for a future deployment, redeployment, disaster-recovery failover, or restart that needs a new allocation. Review capacity and recovery plans before an operation that releases capacity. [Modernization FAQ][modernization-faq] | [Capacity restrictions][retirements]

</details>

<details>
<summary>Q6. Will Microsoft automatically move my workload to a replacement size?</summary>

Do not rely on automatic migration. **Recommended action:** Choose replacement sizes and complete modernization before retirement. Remaining affected VMs are deallocated at retirement; workload migration is not guaranteed. For service-managed compute, follow that service's replacement process. [Lifecycle overview][lifecycle] | [Workload patterns][discover]

</details>

## 2. Reserved Instances

<details>
<summary>Q7. Do capacity restrictions cancel existing Reserved Instances?</summary>

No. Existing Reserved Instances (RIs) remain valid for their purchased term and continue discounting matching usage after quota growth restrictions take effect. An RI is a billing benefit, not a capacity reservation or an exemption from retirement. [RI questions in the capacity-restrictions guidance][retirements]

</details>

<details>
<summary>Q8. Will an RI automatically follow a move from v3 to v5, v6, or v7?</summary>

Do not assume it will. Matching depends on the reservation's applicable region, benefit scope, and eligible usage. Instance-size flexibility shares the benefit only among sizes in the same flexibility group; it is not a general cross-generation transfer right. Verify the actual group and target before moving. [VM size flexibility][vm-flexibility] | [Current instance-size flexibility reference][flexibility]

</details>

<details>
<summary>Q9. Can I exchange an RI for a replacement family?</summary>

Possibly, if the reservation and replacement meet the current exchange policy.

Currently, an announced exchange-policy change takes effect starting **February 1, 2027**: reservations purchased after that date are not exchangeable where the service is supported by savings plans; reservations purchased before that date retain one final exchange. The policy explicitly lists exclusions, including reservations for deprecated products or services approaching end of life.

Do not treat February 1 as a universal deadline after which every legacy reservation loses exchange rights. Confirm the specific reservation's eligibility and transaction conditions before relying on an exchange. [Exchange and refund policy][exchange]

</details>

<details>
<summary>Q10. Can I trade an RI for a savings plan?</summary>

Eligible reservations can be traded in through the documented trade-in process. This is a commercial transaction, not an automatic conversion. The new savings plan's total commitment must be at least the returned reservation's remaining commitment.

The resulting hourly commitment is not guaranteed to cover exactly the same VMs or deliver the same savings as the RI. Compare eligible usage and prices before deciding. [Reservation trade-ins][trade-in]

</details>

<details>
<summary>Q11. What if the original RI remains active after I migrate?</summary>

If no matching usage consumes the reservation, utilization can fall and the commitment can be unused. Check whether other eligible usage within its scope can consume the benefit; otherwise evaluate eligible exchange, refund, or trade-in options under the current rules. Migration alone does not cancel the reservation. [Size flexibility][flexibility] | [Exchange policy][exchange] | [Trade-ins][trade-in]

</details>

<details>
<summary>Q12. Can I still buy or renew RIs for these older series?</summary>

Not for the affected series and terms after their published cutoff. Starting **July 1, 2026**, purchases and renewals are unavailable for:

- **One-year RIs:** Av2, Amv2, Bv1, D, Ds, Dv2, Dsv2, F, Fs, Fsv2, G, Gs, Ls, and Lsv2.
- **One-year and three-year RIs:** Dv3, Dsv3, Ev3, and Esv3.

Other series and terms can have earlier, separate cutoffs. Existing reservations continue through their purchased term. An RI purchase cutoff is not a VM shutdown date. [Legacy reservation transition guide][legacy-ri] | [Series-specific schedule][modernization-guide]

</details>

<details>
<summary>Q13. Does an RI guarantee capacity or override growth restrictions?</summary>

No. RIs provide pricing benefits, not guaranteed allocation. On-demand capacity reservations are a different feature. An RI does not make a blocked quota increase available or guarantee redeployment, failover, or scale-out. [Capacity restrictions][retirements] | [Capacity reservation overview][capacity]

</details>

## 3. Azure savings plan for compute

<details>
<summary>Q14. What happens to an existing savings plan when I change VM families?</summary>

The commitment continues. Its benefit can apply to eligible replacement usage within the benefit scope; it is not tied to a particular VM family or region in the way a VM reservation is. The migration does not cancel or restart the term. [Reservations versus savings plans][compare] | [Manage savings plans][manage-plan]

</details>

<details>
<summary>Q15. Can a savings plan cover v5, v6, or v7 VMs?</summary>

It can cover eligible compute usage from those series within the plan's scope. Check the actual target meter, offer eligibility, and savings-plan rate. A newer version number alone is not evidence of the benefit or its amount. [How discounts apply][discount]

</details>

<details>
<summary>Q16. Can the benefit apply after moving to another region?</summary>

Yes, for eligible usage within the plan's benefit scope. Azure savings plan for compute is not restricted to a single region. Confirm that the destination resource remains in scope and eligible. [Reservations versus savings plans][compare] | [Manage savings plans][manage-plan]

</details>

<details>
<summary>Q17. What if modernization reduces my eligible compute spend?</summary>

The purchased hourly commitment stays the same. Each hour's benefit is use-it-or-lose-it and does not roll over. If eligible usage at the applicable rates does not consume the commitment, part of that hour's benefit is unused. Do not buy additional commitments solely on the basis of pre-migration usage. [Discount application][discount] | [Commitment planning][compare]

</details>

<details>
<summary>Q18. Can I reduce or cancel an existing savings plan?</summary>

You cannot change the purchased hourly commitment or term length, or cancel or exchange the plan. Benefit scope can be changed under the documented rules, but that does not reduce the commitment or change the term. [Manage savings plans][manage-plan]

</details>

<details>
<summary>Q19. Can I use RIs and a savings plan together?</summary>

Yes. Azure applies matching reservation benefits first, then savings-plan benefits to remaining eligible usage. They do not both discount the same unit of usage. Review overall utilization to avoid unused commitments after migration. [Benefit application][discount]

</details>

## 4. Modernization compatibility

<details>
<summary>Q20. Is v6 or v7 always the required replacement, and can I just resize?</summary>

No. Retirement requires leaving the retiring size, not universally moving to v6 or v7.

For Dv3/Dsv3/Ev3/Esv3, **Recommended action:** Use v5 for the smoothest transition, or evaluate v6/v7 for the latest features and performance. Supported Extended sizes can be valid replacements; they are not retired merely because a newer generation exists.

A v6/v7 move can change boot generation, storage presentation, networking, and image requirements. Treat it as platform modernization, not an assumed drop-in resize. Parallel replacement is the recommended approach for this path; eligible in-place paths have separate prerequisites. [v5 transition guidance][v5] | [v6/v7 planning][plan] | [Modernization FAQ][modernization-faq]

</details>

<details>
<summary>Q21. Can a Generation 1 VM become Generation 2 in place?</summary>

An eligible Gen1 VM can upgrade through the documented **Trusted Launch** path. Gen1-to-Gen2 conversion without enabling Trusted Launch is not supported.

This is not a normal resize. The VM size, OS, disk layout, encryption, and backup configuration must meet the upgrade prerequisites. Dv2 and Dv3 are listed as unsupported Trusted Launch source series; do not promise direct conversion while remaining on those sizes. The upgrade documentation describes moving unsupported source sizes to supported families where applicable.

**Microsoft support limits:** The documented upgrade excludes Windows Server 2016, Debian, and Azure Linux. Linux upgrades require supported Azure Marketplace OS images; do not assume a custom Linux image qualifies. If Azure Backup is enabled, it must use the Enhanced policy, not Standard. If Azure Site Recovery is enabled, the upgrade prerequisites require disabling it before the upgrade and reconfiguring it afterward. Verify the current [upgrade prerequisites][gen1-prerequisites] and [unsupported configurations][gen1-unsupported] before selecting this path.

There is no simple rollback to Gen1: plan recovery from a verified pre-upgrade backup. A new VM from a compatible Gen2 image is the alternative when the in-place path is unsuitable. [Gen1 upgrade prerequisites][gen1] | [Trusted Launch size support][trusted] | [Modernization planning][plan]

</details>

<details>
<summary>Q22. What changes when moving from SCSI to NVMe?</summary>

The OS must discover disks through NVMe. Validate boot support, drivers, disk enumeration, mount configuration, recovery tooling, and application disk references. Hard-coded SCSI paths must be replaced with appropriate stable identifiers.

An in-place conversion is available for eligible configurations, so the change is not universally impossible. However, the commonly referenced automation is a **community utility, not an officially supported Microsoft tool**, and has configuration-specific limits. Do not use it as proof that every VM can convert. [Readiness assessment][assess] | [SCSI-to-NVMe conversion][nvme-conversion]

**Microsoft-documented limits:** NVMe requires Generation 2; a Gen1 VM needs a supported conversion or replacement first. The utility's documented standard path is for source VMs without a local temporary disk. Temporary-disk source scenarios have separate preview requirements, including `VMTempDiskResizePreview`; do not assume the standard utility path covers them. The utility does not detect Linux ADE and can complete while leaving an unsupported configuration. Review the [conversion prechecks][nvme-prechecks] and Q23 rather than treating decryption alone as proof of support.

</details>

<details>
<summary>Q23. What OS, networking, and encryption checks are needed for v6/v7?</summary>

Validate all of these against the exact target series and image:

- Generation 2/UEFI and the applicable security configuration.
- NVMe-ready OS and storage drivers.
- **Microsoft Azure Network Adapter (MANA)** OS and driver readiness.
- Current, compatible low-level security, backup, and monitoring agents.
- **Azure Disk Encryption (ADE):** ADE is unavailable on v6/v7 for both operating systems. Treat ADE as a migration-design gate and review the supported replacement encryption model before selecting a path.

Do not assume that decrypting a disk alone makes every conversion or encryption-at-host scenario supported. [Readiness assessment][assess] | [Modernization planning, including ADE][plan]

**Separate Microsoft retirement policy:** ADE retires on **September 15, 2028**. ADE-enabled workloads can continue running, but encrypted disks will fail to unlock after VM reboots following retirement. This deadline is separate from VM-series retirement dates. Review the [Windows ADE support and retirement guidance][ade-windows] or [Linux ADE support and retirement guidance][ade-linux], as applicable.

</details>

<details>
<summary>Q24. Can I keep the same CPU manufacturer?</summary>

Often, by selecting an appropriate Intel or AMD target, subject to compatible sizes and availability. Confirm CPU architecture, required instructions, vendor certification, and workload performance.

**Tool behavior:** The tool preserves CPU architecture and prioritizes the same CPU vendor. Its explicit v6/v7 modernization selection requires the same vendor, but normal retirement/upgrade selection can fall back to another x64 vendor when no valid same-vendor candidate exists. The fallback is flagged as **CPU Vendor Change Required** and lowers confidence. If no suitable v6/v7 target exists, the normal recommendation is retained as fallback. This is a tool policy, not a general Microsoft requirement to retain the CPU vendor. [Candidate selection methodology][tool-selection] | [v5 target families][v5]

**Evidence quality:** When the processor catalog lacks verified evidence, CPU vendor can be inferred from SKU naming and marked partially verified. Review the vendor quality and validation items before relying on a vendor-preservation result. [Tool evidence and methodology][tool-method]

</details>

<details>
<summary>Q25. Will temporary storage behave the same way?</summary>

No. For the D/E v6/v7 modernization path, local temporary storage is associated with `d` variants and is presented through NVMe. Validate capacity, disk initialization, page file, caches, and SQL Server tempdb placement. Do not retain persistent application data there.

Also inventory state on the **OS disk**: a new VM built from a fresh image does not automatically receive the source VM's application configuration, certificates, license files, or local data. Explicitly migrate what must persist. [Temporary and OS-disk considerations][plan]

</details>

<details>
<summary>Q26. Are third-party appliances and applications automatically supported?</summary>

No. For SAP and certified ISV appliances, confirm the exact supported target family before choosing a migration design. Then validate the image, OS, licensing, NIC layout, storage presentation, driver versions, and support path. Platform compatibility alone does not establish vendor certification. [Assessment gates][assess] | [Workload classification][discover]

</details>

## 5. Quota, availability, and capacity

<details>
<summary>Q27. Does existing quota transfer automatically to the target family?</summary>

Do not assume so. Azure checks both total regional vCPU quota and VM-family vCPU quota for each subscription and region. Check target-family headroom and the regional total, including the period when old and new VMs coexist. A quota restriction on the old family is not a statement that the target family cannot receive quota. [vCPU quotas][quotas] | [Migration planning][plan]

</details>

<details>
<summary>Q28. Does approved quota or a listed regional SKU guarantee deployment?</summary>

No. Quota is an approved subscription limit; capacity is the underlying hardware available for allocation in the requested location. A deployment can fail with sufficient quota. A SKU being listed is not a reservation of physical capacity. [Quota and capacity][quotas] | [Capacity restrictions][retirements]

</details>

<details>
<summary>Q29. What if the recommended size is unavailable?</summary>

Evaluate another compatible size, zone, region, or schedule. Recheck application certification, data location, networking, latency, and resilience requirements before changing the plan. Do not silently replace a required zonal architecture with a regional deployment. [Regional and zonal planning][plan] | [Modernization FAQ][modernization-faq]

</details>

<details>
<summary>Q30. What about disaster recovery and high availability?</summary>

Validate supported sizes, quota, allocation capacity, recovery mechanisms, and placement in both primary and recovery locations. Preserve the intended zone and cluster layout while old and new nodes coexist.

An RI or approved quota does not guarantee a recovery allocation. Test the applicable recovery and failover process. [Capacity-restriction RI FAQ][retirements] | [Cluster and capacity planning][plan]

</details>

<details>
<summary>Q31. Can on-demand capacity reservations help?</summary>

For supported scenarios, an on-demand capacity reservation reserves a specific size and location after successful creation, with coverage under the applicable capacity SLA. Creation itself requires sufficient quota and available capacity; it can fail.

Used and unused reserved capacity can incur charges. Eligible reservation or savings-plan benefits may apply. This feature is not an RI and is not a workaround for missing quota. Existing affected-series reservations can continue within their limits; shared cross-subscription arrangements need special quota review. [Capacity reservation overview][capacity] | [Affected-series capacity reservation FAQ][retirements]

</details>

## 6. Migration, downtime, and rollback

<details>
<summary>Q32. Will migration require downtime?</summary>

It depends on the chosen method and application architecture. A resize can require restart or deallocation. Parallel replacement still requires a controlled cutover; replication or clustering may reduce disruption but does not establish a universal zero-downtime guarantee. [v5 transition methods][v5] | [v6/v7 planning][plan]

</details>

<details>
<summary>Q33. What is the recommended v6/v7 pattern?</summary>

**Recommended action for customer-managed VMs:**

**Deploy compatible replacements -> Move application and data -> Validate -> Cut over -> Retire old resources after acceptance.**

Begin with a pilot and proceed in controlled waves. For pools, managed services, clusters, and appliances, use the workload-specific replacement process rather than applying a per-VM runbook indiscriminately. [Plan the modernization][plan] | [Workload patterns][discover]

</details>

<details>
<summary>Q34. Is rollback always possible?</summary>

No. Define and test it for the actual execution method.

- Parallel replacement can preserve the old environment until the new one is accepted; define how clients and any changed application state would move back.
- An eligible SCSI-to-NVMe conversion has a documented controller/size revert.
- Gen1-to-Trusted-Launch conversion does not simply revert to Gen1; recovery requires the pre-upgrade backup.
- A retired source size cannot remain your fallback after its retirement date.

Do not confuse possession of a backup with a tested recovery. [Rollback FAQ][modernization-faq] | [Conversion revert][nvme-conversion]

</details>

<details>
<summary>Q35. How should Azure Virtual Desktop be handled?</summary>

Separate pooled/non-persistent hosts from personal/persistent desktops. For pooled hosts, assess and refresh the golden image, introduce canary hosts, drain sessions, and expand in rings. Verify profiles and application state are externalized.

Personal desktops bind users to individual VMs and require per-VM assessment and state migration. Do not apply an image-only replacement assumption to them. [Desktop workload patterns][discover] | [Modernization FAQ][modernization-faq]

</details>

<details>
<summary>Q36. How should AKS be handled?</summary>

**What happens to nodes on retiring SKUs?** Retirement of the underlying VM size also affects AKS worker nodes. End of Life means retirement is announced, not that nodes are already stopped. Capacity growth restrictions alone do not stop running nodes, but scale-out, replacement, upgrade surge, and recovery allocations can be constrained. At retirement, Microsoft's VM lifecycle policy says remaining VMs on retired sizes are deallocated and can no longer run on those sizes. Do not assume AKS will automatically move the pool to another SKU. [Lifecycle policy][lifecycle] | [Capacity restrictions][retirements]

**Does a Kubernetes or node-image upgrade fix SKU retirement?** Not by itself. Updating Kubernetes or the node OS image does not by itself change the pool's VM size. Plan replacement capacity on a supported, non-retiring SKU.

**What is the recommended replacement path?** Use the AKS node-pool replacement workflow:

1. Confirm the target SKU is supported by AKS for the required OS, region and zones. Check target-family and regional vCPU quota, allocation capacity, and subnet/pod IP headroom while old and new pools coexist.
2. Create a replacement pool through AKS. Preserve required labels, taints, autoscaler settings, disk configuration and pod density; do not assume these settings are inherited.
3. Validate representative workloads, node selectors/affinity, topology constraints, networking, DaemonSets and persistent-volume attachment on the new nodes.
4. Confirm replicas and PodDisruptionBudgets allow eviction, then cordon and drain old nodes progressively. Node-local and `emptyDir` data are not automatically migrated; review deletion flags and application state before draining.
5. Verify application and system-pod health before removing the old pool. Update infrastructure-as-code and autoscaling settings so the retiring SKU is not recreated.

[Microsoft replacement-pool steps][aks-replacement] | [AKS SKU and region limits][aks-limits] | [Compute-pool modernization guidance][discover]

**What differs for system and user pools?** Keep at least one eligible System pool throughout the change. Before removing an old System pool, create another Linux System pool meeting the current AKS requirements (at least two nodes; three recommended for production fault tolerance). Adding a System pool or changing pool mode does not automatically move existing system pods. For user pools, preserve workload-specific scheduling and OS/SKU requirements, including Windows or GPU dependencies where applicable. [System-pool requirements and replacement][aks-system]

**Is this zero-downtime or an automatic data migration?** No. Disruption depends on replicas, disruption budgets, scheduling, capacity and storage behavior. Persistent volumes need access-mode, zone and detach/attach validation; node-local data needs an explicit application-level strategy.

**Can I resize the backing VMs or run standalone conversion utilities?** Do not modify the backing VMs/VMSS directly or apply standalone Gen1/NVMe conversion utilities to AKS-managed nodes. Use AKS-supported pool operations. This answer covers the recommended replacement-pool path only; it does not imply that this tool inventories AKS pools or validates their readiness.

</details>

<details>
<summary>Q37. What should be validated after cutover?</summary>

Verify OS boot, application and data integrity, disk paths and performance, networking, security agents, monitoring, backup/restore, availability, and workload-owner acceptance. Confirm reservation/savings-plan utilization and licensing configuration separately. A successful boot alone is not successful modernization. [Readiness checklist][assess] | [Planning guidance][plan] | [Modernization FAQ][modernization-faq]

</details>

## 7. Assessment and planning

<details>
<summary>Q38. What should a retirement assessment contain?</summary>

A useful planning assessment identifies affected resources, exact source sizes, subscriptions, regions, lifecycle evidence and dates, candidate replacements, platform prerequisites, quota and restriction checks, uncertainty, and next steps.

It must distinguish observed facts from guest/workload checks that remain open. A control-plane assessment alone cannot certify application compatibility, vendor support, or physical capacity. [Assessment checklist][assess] | [Tool data sources and blind spots][tool-sources]

</details>

<details>
<summary>Q39. Does a recommended or compatible size guarantee migration success?</summary>

No. It is a candidate based on the evidence checked. Guest drivers, OS and image readiness, application dependencies, licensing, capacity, and recovery still need validation. This tool's confidence and readiness indicators are not a deployment guarantee. [Readiness guidance][assess] | [Tool documentation][tool]

**Tool evidence quality:** Some CPU vendor information can be inferred from SKU naming rather than verified processor tables. Check vendor quality, lifecycle provenance, and open validation items; a compatibility label does not turn inferred evidence into a verified fact. [Tool methodology][tool-method]

</details>

<details>
<summary>Q40. When should planning start?</summary>

Start after an applicable retirement or growth-restriction announcement, leaving time for assessment, target quota, commercial review, pilots, phased cutover, and tested rollback before retirement.

Prioritize using the actual retirement date and workload risk. A growth restriction is a reason to plan expansion and recovery carefully, not evidence of an immediate forced shutdown. [Lifecycle actions][lifecycle] | [Modernization planning][plan]

</details>

## 8. Understanding this tool

<details>
<summary>Q41. Does the tool make changes to Azure?</summary>

No. The documented tool is strictly read-only. It collects inventory and evidence and produces recommendations; it does not resize, stop, start, redeploy, request quota, or modify configuration. This FAQ describes customer planning options, not actions the tool performs. [Tool documentation][tool]

</details>

<details>
<summary>Q42. Does the tool assess RI coverage or show my actual contracted bill?</summary>

No. The repository documents that RI and savings-plan coverage are not assessed. Retail PAYGO comparisons are informational and exclude agreement discounts, reservations, savings plans, and Azure Hybrid Benefit.

**RI coverage and net cost: Not assessed**. See [Reserved Instances](#2-reserved-instances) for existing benefits, expiration and migration considerations.

Commercial answers in this FAQ explain Microsoft policy; they are not evidence that the tool has inspected your commitments or calculated your net savings. Its optional rightsizing signal does not change the recommended size. [Tool documentation and limitations][tool]

</details>

<details>
<summary>Q43. What do End of Life, Retired, optional modernization, and unknown results mean in the report?</summary>

- **End of Life:** retirement has been announced; plan migration before the recorded deadline.
- **Retired:** the evidence identifies an already-retired series or a retirement date reached by the assessment date.
- **Optional modernization:** a newer-generation opportunity without an established retirement requirement.
- **Unable to Confirm / Unable to Verify:** lifecycle evidence or a particular check remains unresolved; manual review is required.

Do not read End of Life as already shut down, optional modernization as mandatory retirement, or an unknown result as safe. Review the evidence URL and assessment date. [Tool methodology][tool-method]

</details>

<details>
<summary>Q44. Does the tool cover every Azure compute workload and readiness check?</summary>

No. The documented inventory does not include Uniform VM Scale Set instances. Guest-dependent facts, including actual temporary-disk use and nested virtualization, need separate review; physical capacity cannot be verified from the control plane.

Check AKS, AVD, managed-service, and other pool/cluster inventories through their supported assessment processes rather than assuming a standalone-VM report is complete. The tool's documented runtime is PowerShell 7.2+ on Windows with Azure CLI 2.60+. [Tool limitations][tool] | [Data sources][tool-sources] | [Workload patterns][discover]

</details>

<details>
<summary>Q45. Can I rely on a cached assessment indefinitely?</summary>

No. The tool records source provenance and distinguishes cached evidence from live retrieval. Its methodology documents warnings for stale or incomplete evidence. Recheck current Microsoft guidance and the target environment before production decisions; unknown or stale results are not lifecycle guarantees. [Evidence handling][tool-method]

</details>

## 9. Planning ahead for retirement

<details>
<summary>Q46. Why start planning retirement migrations now instead of waiting?</summary>

Start with inventory, assessment and a pilot now; schedule migration waves according to the actual retirement deadline and workload risk. This does **not** mean every VM must be resized immediately. An announced End of Life size is still supported until retirement, subject to its applicable restrictions.

- **Quota and capacity:** Growth restrictions can limit additional quota or new deployments on affected older series. Check target-family and regional quota and target availability in the required region and zone early. Approved quota or an offered SKU does not guarantee physical capacity.
- **Potential CPU and hardware benefits:** Some newer sizes offer newer processors and platform features that may improve performance or efficiency. Benchmark representative workloads: the same vCPU count or a newer generation does not guarantee faster performance.
- **Disk and networking capabilities:** Some targets offer higher IOPS, throughput or networking limits, while others may reduce them. Compare current and target VM-level and disk-level limits against observed workload demand; validate temporary-disk requirements as well.
- **Compatibility and safe cutover:** Allow time to validate the OS image, Gen1/Gen2, NVMe or SCSI, networking drivers, encryption and vendor support. Pilot, test application performance and recovery, then migrate in controlled waves.
- **Avoid deadline pressure:** Coordinate owners, maintenance windows, licensing, reservation coverage, high availability and tested rollback. Once a source SKU is retired, it cannot be relied on as the rollback target.

Starting early improves planning options; it does not guarantee target capacity, a lower bill, higher performance or a successful migration. [Capacity restrictions][retirements] | [Modernization planning][plan] | [v5 modernization][v5]

</details>

<a id="retirement-and-price-change-sku-scope"></a>

## Retirement and RI eligibility

**Which SKUs are retiring?** The selected series below have published retirement deadlines; this is not an exhaustive list of retired or retiring sizes. Use Q3, each VM's exact SKU and evidence link, and the [official retirement schedule][retirements] for full scope.

| Selected series | Published retirement date | RI purchase/renewal restriction from July 1, 2026 |
|---|---|---|
| D, Ds, Dv2, Dsv2, Ls | May 1, 2028 | One-year RI unavailable; other terms can have separate earlier cutoffs |
| Av2/Amv2, B-series v1, F, Fs, Fsv2, G, Gs, Lsv2 | November 15, 2028 | One-year RI unavailable; other terms can have separate earlier cutoffs |
| Dv3, Dsv3, Ev3, Esv3 | November 15, 2029 | One-year and three-year RI unavailable |
| Other sizes, including candidate v5/v6/v7 replacements | Check the exact series, cloud and current lifecycle evidence; version alone does not establish lifecycle status | Check the exact reservation product and term |

The Dv3/Dsv3/Ev3/Esv3 retirement covers all 32 sizes in those series, excluding Azure Government, Azure operated by 21Vianet and sovereign cloud regions for **that retirement announcement only**. RI term restrictions come from the [legacy RI transition guide][legacy-ri].

## Service Health notice register

These example IDs were observed in a prior assessment and may not apply to every subscription. Their links open
related Microsoft guidance, not the individual Service Health notices.

| Service Health ID and topic | Related official Microsoft guidance | Evidence boundary |
|---|---|---|
| [`PRFR-_4Z`][retirements] - VM retirement and modernization | [Retirement schedule][retirements] and [modernization guide][modernization-guide] | Supports lifecycle interpretation, not a full price-affected SKU list |
| [`JGW1-KG0`][service-health] - Regional pricing updates | [Azure Service Health][service-health] and [Azure pricing calculator][pricing-calculator] | Locate the full notice and check applicable pricing dimensions; the calculator is not the notice or proof of a future increase |
| [`HZ28-GKZ`][legacy-ri] - Reserved Instance eligibility | [Legacy RI transition][legacy-ri] and [reservation discount application][ri-discount] | Explains purchase/renewal restrictions and existing benefits, not actual tenant coverage |

These are **related guidance links**, not public copies of the full notices. In [Azure Service Health][service-health], locate the event by its tracking ID using your existing read access. If the event is unavailable, obtain an authorized saved copy; do not infer missing details. The collector currently includes retirement-subtype Health Advisories only, so this guidance is not a complete list of pricing advisories.

## Sources and scope

This FAQ accompanies the independently developed VM SKU Retirement tool. It is not an official Microsoft support statement or a tenant-specific assessment. Sources were checked on October 21, 2026. Dates, regional/cloud scope, eligibility, and commercial policies can change.

The retirement schedule, legacy RI transition, reservation discount application and Service Health references were rechecked on November 2, 2026 for the commercial sections. This does not revalidate every other FAQ topic.

Answers link to the relevant documentation. Use the dedicated lifecycle and commercial references for policy details and the repository documentation for tool behavior. Generic migration examples are not universal support guarantees.

**How to read the answers:** Microsoft policy and support limits describe published service rules, subject to their stated eligibility and scope. Tool behavior describes this repository's implementation, not Microsoft policy. Recommendations about pilots, validation, cutover, and recovery are planning guidance, not guarantees of compatibility, capacity, or zero downtime.

### Change-sensitive source checks

These are the published page update dates observed during the October 21, 2026 review, not policy effective dates. The linked pages can change after review; recheck them before acting.

| Topic | Microsoft source | Page last updated | Last reviewed |
|---|---|---|---|
| Retirement and capacity restrictions | [Lifecycle schedule][retirements] | September 25, 2026 | October 21, 2026 |
| RI purchase and renewal cutoffs | [Legacy RI transition][legacy-ri] | May 4, 2026 | October 21, 2026 |
| RI exchange eligibility | [Exchange policy changes][exchange-policy] | July 29, 2026 | October 21, 2026 |
| Gen1 upgrade eligibility | [Upgrade prerequisites][gen1-prerequisites] | June 19, 2026 | October 21, 2026 |
| Community NVMe utility limits | [Conversion prechecks][nvme-prechecks] | September 26, 2026 | October 21, 2026 |

ADE support and its separate retirement deadline were also checked on October 21, 2026 against the dedicated [Windows][ade-windows] and [Linux][ade-linux] documentation.

This FAQ does not perform assessments or change Azure resources.

### Microsoft lifecycle and modernization references

- [VM lifecycle overview][lifecycle]
- [Retirements and capacity growth restrictions][retirements]
- [End of Life series][eol]
- [Retired sizes modernization guide][modernization-guide]
- [v6/v7 modernization FAQ][modernization-faq]
- [v6/v7 planning][plan]
- [v6/v7 readiness assessment][assess]
- [v5 modernization][v5]
- [Workload-specific modernization patterns][discover]
- [Gen1-to-Trusted-Launch upgrade][gen1]
- [Trusted Launch supported sizes and configurations][trusted]
- [SCSI-to-NVMe conversion and tool limitations][nvme-conversion]
- [Windows Azure Disk Encryption support and retirement][ade-windows]
- [Linux Azure Disk Encryption support and retirement][ade-linux]
- [AKS replacement-pool workflow][aks-replacement]
- [AKS system node-pool requirements][aks-system]
- [AKS quotas, supported SKUs and regions][aks-limits]
- [vCPU quotas][quotas]
- [On-demand capacity reservations][capacity]

### Microsoft commercial references

- [Legacy VM reservation transition][legacy-ri]
- [Reservation discount application][ri-discount]
- [Azure Service Health][service-health]
- [Azure pricing calculator][pricing-calculator]
- [Azure Retail Prices API][retail-prices]
- [Azure VM pricing][vm-pricing]
- [EA billing-account price sheet][ea-price-sheet]
- [MCA/MPA billing-profile price sheet][mca-price-sheet]
- [Health Advisory impacted resources][impacted-resources]
- [Reservation exchanges and refunds][exchange]
- [Reservation trade-ins][trade-in]
- [Reserved VM instance-size flexibility][vm-flexibility]
- [Current instance-size flexibility reference][flexibility]
- [Reservations versus savings plans][compare]
- [Manage savings plans][manage-plan]
- [Savings-plan discount application][discount]

### Tool references

- [Repository README][tool]
- [Assessment methodology][tool-method]
- [Data sources, permissions, and blind spots][tool-sources]

[lifecycle]: https://learn.microsoft.com/en-us/azure/virtual-machines/sizes/lifecycle/lifecycle-overview
[retirements]: https://learn.microsoft.com/en-us/azure/virtual-machines/sizes/lifecycle/retirements-and-capacity-restrictions
[eol]: https://learn.microsoft.com/en-us/azure/virtual-machines/sizes/lifecycle/end-of-life-sizes-list
[modernization-guide]: https://learn.microsoft.com/en-us/azure/virtual-machines/sizes/lifecycle/retirement/retired-sizes-modernization-guide
[modernization-faq]: https://learn.microsoft.com/en-us/azure/virtual-machines/sizes/lifecycle/sizes-v6-v7-modernization-faq
[plan]: https://learn.microsoft.com/en-us/azure/virtual-machines/sizes/lifecycle/sizes-v6-v7-modernization-plan
[assess]: https://learn.microsoft.com/en-us/azure/virtual-machines/sizes/lifecycle/sizes-v6-v7-modernization-assess
[v5]: https://learn.microsoft.com/en-us/azure/virtual-machines/sizes/lifecycle/sizes-v5-modernization-overview
[discover]: https://learn.microsoft.com/en-us/azure/virtual-machines/sizes/lifecycle/sizes-v6-v7-modernization-discover
[gen1]: https://learn.microsoft.com/en-us/azure/virtual-machines/trusted-launch-existing-vm-gen-1
[trusted]: https://learn.microsoft.com/en-us/azure/virtual-machines/trusted-launch
[nvme-conversion]: https://learn.microsoft.com/en-us/azure/virtual-machines/migration/scsi-to-nvme-migration
[quotas]: https://learn.microsoft.com/en-us/azure/virtual-machines/quotas
[capacity]: https://learn.microsoft.com/en-us/azure/virtual-machines/capacity-reservation-overview
[legacy-ri]: https://learn.microsoft.com/en-us/azure/cost-management-billing/reservations/manage-legacy-vm-reservations-after-july-1-2026
[ri-discount]: https://learn.microsoft.com/en-us/azure/cost-management-billing/reservations/reservation-discount-application
[service-health]: https://learn.microsoft.com/en-us/azure/service-health/overview
[pricing-calculator]: https://azure.microsoft.com/en-us/pricing/calculator/
[retail-prices]: https://learn.microsoft.com/en-us/rest/api/cost-management/retail-prices/azure-retail-prices
[vm-pricing]: https://azure.microsoft.com/en-us/pricing/details/virtual-machines/windows/
[ea-price-sheet]: https://learn.microsoft.com/en-us/rest/api/cost-management/price-sheet/download-by-billing-account
[mca-price-sheet]: https://learn.microsoft.com/en-us/rest/api/cost-management/price-sheet/download-by-billing-profile
[impacted-resources]: https://learn.microsoft.com/en-us/azure/service-health/impacted-resources-retirements
[exchange]: https://learn.microsoft.com/en-us/azure/cost-management-billing/reservations/exchange-and-refund-azure-reservations
[trade-in]: https://learn.microsoft.com/en-us/azure/cost-management-billing/savings-plan/reservation-trade-in
[vm-flexibility]: https://learn.microsoft.com/en-us/azure/virtual-machines/reserved-vm-instance-size-flexibility
[flexibility]: https://learn.microsoft.com/en-us/azure/cost-management-billing/reservations/instance-size-flexibility
[compare]: https://learn.microsoft.com/en-us/azure/cost-management-billing/savings-plan/decide-between-savings-plan-reservation
[manage-plan]: https://learn.microsoft.com/en-us/azure/cost-management-billing/savings-plan/manage-savings-plan
[discount]: https://learn.microsoft.com/en-us/azure/cost-management-billing/savings-plan/discount-application
[tool]: https://github.com/AzaryaShaulov/VMSKURetirementReport/blob/main/README.md
[tool-method]: https://github.com/AzaryaShaulov/VMSKURetirementReport/blob/main/skills/vm-sku-retirement-report/references/methodology.md
[tool-sources]: https://github.com/AzaryaShaulov/VMSKURetirementReport/blob/main/skills/vm-sku-retirement-report/references/data-sources.md
[gen1-prerequisites]: https://learn.microsoft.com/en-us/azure/virtual-machines/trusted-launch-existing-vm-gen-1#prerequisites
[gen1-unsupported]: https://learn.microsoft.com/en-us/azure/virtual-machines/trusted-launch-existing-vm-gen-1#unsupported-gen1-vm-configurations
[nvme-prechecks]: https://learn.microsoft.com/en-us/azure/virtual-machines/migration/scsi-to-nvme-migration#before-you-run-the-conversion
[ade-windows]: https://learn.microsoft.com/en-us/azure/virtual-machines/windows/disk-encryption-overview
[ade-linux]: https://learn.microsoft.com/en-us/azure/virtual-machines/linux/disk-encryption-overview
[exchange-policy]: https://learn.microsoft.com/en-us/azure/cost-management-billing/reservations/exchange-and-refund-azure-reservations#reservation-exchange-policy-changes
[tool-selection]: https://github.com/AzaryaShaulov/VMSKURetirementReport/blob/main/skills/vm-sku-retirement-report/references/methodology.md#6-selection
[aks-replacement]: https://learn.microsoft.com/en-us/azure/aks/resize-node-pool#create-a-new-node-pool-with-the-desired-sku
[aks-system]: https://learn.microsoft.com/en-us/azure/aks/use-system-pools
[aks-limits]: https://learn.microsoft.com/en-us/azure/aks/quotas-skus-regions
