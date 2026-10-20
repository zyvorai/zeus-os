# Page-by-page guides

Each guide follows the same shape:

1. **Purpose** — what this screen is for
2. **When to use it** — typical jobs
3. **How to get there** — route and nav path
4. **Operate from the console (UX)** — concrete clicks after you land
5. **Related pages** — where to go next

Every dashboard route, including screens without a deep guide, is listed in the
[complete page index](../PAGE_INDEX.md).

## Core — VMs and daily operations

| Page | What it covers |
|------|----------------|
| [Favorites](core/favorites.md) | Pinned VM list for quick access: star VMs you care about, search the fleet, and open VNC or serial console deep links. |
| [Home (Mission Control)](core/home.md) | Apple.com-style chapter home: greeting hero, Get the highlights (fleet KPIs on a dark band), infrastructure pulse, a light Attention teaser, running machines, and apps/insights — without the heavy triage deck. |
| [Instance types](core/instance-types.md) | Browse KubeVirt instance types and preferences — standardized CPU/memory shapes for consistent VM sizing. |
| [Compare VMs](core/vm-compare.md) | Side-by-side diff of two VMs’ configuration so you can spot drift, clone mistakes, or environment mismatches. |
| [VM setup (create a machine)](core/vm-setup.md) | Guided creation of a new KubeVirt VM from instance types, preferences, templates, or AI-assisted manifests. |
| [VM workbench](core/vm-workbench.md) | Full-page operations surface for one virtual machine: power, console, hardware, networking, backup panels, guest agent, and remote access. |
| [VM fleets (VMIRS)](core/vmirs.md) | Manage VirtualMachineInstanceReplicaSet-style fleets — scale homogeneous VM groups as a unit. |
| [VM Instances (VMI)](core/vmis.md) | List of running VirtualMachineInstance objects — the live pods/instances behind VirtualMachine definitions. |
| [Virtual Machines](core/vms.md) | Inventory of every KubeVirt virtual machine you can see: live status, filters, and entry into the per-VM workbench. |

## Consoles and remote access

| Page | What it covers |
|------|----------------|
| [ConsoleHub](consoles/consolehub.md) | Unified launcher and session manager for browser consoles — multiple VMs, policies, and session visibility. |
| [Consoles & remote access](consoles/overview.md) | Reach the guest: graphical VNC, serial text console, and native RDP/SSH via NodePort expose. |

## Cluster, storage and images

| Page | What it covers |
|------|----------------|
| [Blueprints](cluster/blueprints.md) | Blueprint Marketplace for one-click application stacks (for example Windows AD, RDS, SQL, IIS, jump boxes) registered in the cluster. |
| [Enterprise networking](cluster/cilium-enterprise-networking.md) | Direct management of Cilium-native Egress Gateway policies, BGP peering, L2 announcement policies, |
| [Customization Profiles](cluster/customization-profiles.md) | Reusable guest customization specs — cloud-init, Windows sysprep/unattend XML, and SSH authorized keys — applied from create/clone flows or onto an existing VM. |
| [DataVolumes](cluster/datavolumes.md) | CDI DataVolume inventory — disk import/clone/upload jobs that back VM disks. |
| [Device Plugins](cluster/device-plugins.md) | Read-only view of Kubernetes device-plugin resources and GPU capacity reported by the cluster. |
| [Disk Manager](cluster/disk-manager.md) | Manage VM disks: attach, hot-plug, resize entry points, and disk inventory beyond the raw PVC list. |
| [GPU Devices](cluster/gpu.md) | GPU / PCI passthrough inventory: host VGA/3D devices, allocation to VMs, plus a vGPU orchestration panel for mdev profiles and assign actions. |
| [HPA](cluster/hpa.md) | Monitor and manage Horizontal Pod Autoscalers — replica counts, CPU utilization, and scaling status across namespaces. |
| [Image Factory](cluster/image-factory.md) | Golden Image Factory pipelines that take a customer-supplied OS ISO through VirtIO, updates, optional GuestKit bake, sysprep/generalize, snapshot, and catalog publish. |
| [Image Library](cluster/image-library.md) | One catalog for golden images, import guidance, and cluster images so operators can pick OS media when creating VMs. |
| [Image Registry](cluster/image-registry.md) | Browse container disk images for KubeVirt VMs — cluster images from running pods, or a reference catalog — then open Create VM with the image prefilled. |
| [MetalLB & external IPs](cluster/metallb-external-ips.md) | Operator guidance for LoadBalancer Services (SSH, RDP, and other external access) via MetalLB address pools — not a pool editor UI. |
| [Networks](cluster/network-attachments.md) | Multus NetworkAttachmentDefinition management so VMs can attach additional L2 NICs — bridge, macvlan, ipvlan, host-device, or SR-IOV. |
| [Nodes](cluster/nodes.md) | Kubernetes worker/control-plane node inventory: capacity, conditions, and drain/placement context for VMs. |
| [Pods](cluster/pods.md) | Kubernetes pod inventory — including `virt-launcher` pods that back running VMIs. |
| [Priority Classes](cluster/priority-classes.md) | Read-only list of Kubernetes PriorityClass objects — numeric value, global default, preemption policy, and usage. |
| [PVC Resize](cluster/pvc-resize.md) | Expand existing PersistentVolumeClaims or create empty PVCs. CDI image imports still belong on DataVolumes. |
| [Runtime Classes](cluster/runtime-classes.md) | Read-only inventory of cluster RuntimeClass objects — handler, scheduling hints, overhead, and usage counts. |
| [Services](cluster/services.md) | Cluster-wide Kubernetes Service inventory for VM SSH/RDP exposes and other workloads — ports, addresses, and YAML in one place. |
| [Storage](cluster/storage.md) | Storage and PVC intelligence for the cluster: volumes, capacity signals, and entry points into disk/resize workflows. |
| [Taints](cluster/taints.md) | Read-only analysis of node taints and which VMs tolerate them — plus scheduling impact warnings for unschedulable guests. |
| [Templates](cluster/templates.md) | Curated VM templates for one-click or guided deploy of known-good shapes. |
| [VPA](cluster/vpa.md) | List, create, and delete Vertical Pod Autoscalers, and inspect container resource recommendations. |
| [Windows via Kryton](cluster/windows-via-kryton.md) |  |

## Observe — health, metrics and incidents

| Page | What it covers |
|------|----------------|
| [Alerts](observe/alerting.md) | Zeus-native alerting console — active fired alerts, threshold rules, history, and webhook destinations — separate from PrometheusRule CRDs in Alerting V2. |
| [APM](observe/apm.md) | Application performance dashboard for services, traces, and latency percentiles — when an APM backend is connected to Zeus OS. |
| [Attention](observe/attention.md) | Ranked next steps, live fleet signals (Issue Stream), and day-2 remediation activity — the triage surface that used to live as a heavy block on Home. |
| [Capacity](observe/capacity.md) | Cluster capacity and overcommit dashboard — utilization pulse, per-node breakdown, capacity alerts, planning scenarios, and HA/DRS context. |
| [Containers](observe/containers.md) | Pod-centric container inventory with status stats, detail sheet, and (for non-viewers) deploy / apply-YAML shortcuts alongside a deployments panel. |
| [Custom Metrics](observe/custom-metrics.md) | Dashboard for operator-defined metrics and their alert rules — create PromQL (or custom) configurations, then watch values and firing alerts. |
| [Events](observe/events.md) | Live Kubernetes event browser — type, reason, object, message, namespace, count, and age — for correlating cluster noise with VM or workload symptoms. |
| [Forecasting](observe/forecasting.md) | AI-assisted resource predictions — per-VM and cluster forecasts, capacity recommendations, and seasonal pattern detection — to plan before you run out of headroom. |
| [Resource Heatmap](observe/heatmap.md) | Cluster-wide utilization heatmap built from per-VM cells rolled up by node — CPU, memory, disk, and network pressure for capacity planning. |
| [Host Info](observe/host.md) | Read-only view of the Zeus OS host — OS, hardware, disks, NICs, and local services — for operators checking the control-plane node itself. |
| [Incident chat](observe/incident-chat.md) | Lightweight multi-user chat channel for incident collaboration. Marked labs in navigation; messages sync through Zeus OS, while slash commands run locally. |
| [Incidents](observe/incidents.md) | Incident center with context and guided remediation — not just a raw alert dump. |
| [Logs Explorer](observe/logs-explorer.md) | On-demand log search across pods in a namespace — query text, severity filter, and optional live tail — for day-2 debugging from the dashboard. |
| [Monitoring Targets](observe/monitoring.md) | Inventory of Prometheus Operator objects in the cluster — ServiceMonitors, Prometheus instances, and PrometheusRule groups — plus high-level monitoring stats. |
| [Network Info](observe/network-info.md) | Host network interface inventory for the Zeus OS host — physical, bridge, veth, VM TAP, Cilium, bond, VLAN, and tunnel devices — with traffic counters. |
| [SLO Manager](observe/slo-manager.md) | Service level objective tracker — create availability-style objectives, watch met / burning / breached status, and refresh error-budget posture for the fleet. |
| [System Health](observe/system-health.md) | Platform health dashboard — control-plane and Zeus-related component pulse for operators and admins. |
| [VM Monitor](observe/vm-monitor.md) | Activity Monitor for the VM fleet — live and historical CPU, memory, network, and disk — with per-VM charts and links into the VM workbench. |

## Run — lifecycle, migration and backup

| Page | What it covers |
|------|----------------|
| [AutoScaler](run/autoscaler.md) | Define policies that resize VMs automatically, and review right-sizing recommendations with their estimated monthly cost impact before applying them. |
| [Backup Wizard](run/backup-wizard.md) | Guided backup workflow for VMs / volumes — complementary to Velero and snapshot managers. |
| [Cluster Autoscale](run/cluster-autoscaling.md) | Read-only status of the cluster autoscaler and its node pools: whether it is enabled, how each pool is sized against its min and max, and what scale-up or scale-down actions it is recommending. |
| [Live Migrations](run/migrations.md) | Plan, dry-run, and execute live VM migrations between nodes with pre-flight checks and history. |
| [Node Drain](run/node-drain.md) | A guided five-step wizard for taking a node out of service safely: pick the node, see exactly which VMs will move and which will lose availability, choose a strategy, cordon and drain, then watch it finish. |
| [Operations](run/operations.md) | One console for the recurring day-2 chores: alert rules, outbound webhooks, quotas, GPU inventory, backup and power and snapshot schedules, RBAC review, quick deploy, cluster context, and labels. |
| [Snapshots](run/snapshots.md) | Create and manage VM snapshots (on-demand and scheduled) for point-in-time recovery. |
| [Velero](run/velero.md) | Velero-backed backup and restore operations for cluster and VM-related resources. |
| [Windows Licensing](run/windows-licensing.md) | Read-only inventory of Windows activation state across your KubeVirt VMs, collected through the guest agent (`slmgr`). Zeus OS never hosts a KMS or redistributes licenses — it reports what your own activation infrastructure says. |
| [Workflows](run/workflows.md) | Read-only view of the automation workflows registered with Zeus OS: what is scheduled, when each last ran, how reliable it has been, and the template gallery you can copy from. |

## Security, compliance and governance

| Page | What it covers |
|------|----------------|
| [Admission control](security/admission-control.md) | Read-only inventory of what intercepts writes to your cluster: validating and mutating admission webhooks, Kyverno policy rules, webhook statistics, and recent admission-related events. |
| [Affinity Rules](security/affinity-rules.md) | Surfaces where your affinity and anti-affinity placement intent is not being honoured — which rule is violated, which VMs are affected, and on which node. |
| [Certificates](security/certificates.md) | Tracks the TLS certificates in your cluster and how long each one has left, so an expiry never surprises you. Renewal can be triggered from the table. |
| [Change Approval](security/change-approval.md) | A review queue for VM changes: destructive requests wait for a human approver, non-destructive ones are auto-approved, and every decision is recorded with a comment and a timestamp. |
| [Compliance](security/compliance.md) | Scores your VMs against Zeus OS policy checks and gives you a cluster grade, per-category pass rates, and a per-VM breakdown you can export as evidence. |
| [External Secrets](security/external-secrets.md) | Monitor the `ExternalSecret` and `SecretStore` resources that pull credentials from Vault, cloud secret managers, and other providers into Kubernetes — with sync, validate, and delete actions. |
| [Image Scanning](security/image-scanning.md) | Vulnerability posture for your container and VM images: critical, high, medium, and low counts per image, when each was last scanned, and the scan policies that decide pass or fail. |
| [OPA Gatekeeper](security/opa.md) | Read-only inventory of your OPA Gatekeeper constraints and constraint templates, with the current violation count and the offending resources behind each one. |
| [PDB](security/pdb.md) | Shows every PodDisruptionBudget in the cluster and whether it currently permits any voluntary disruption — the fastest way to know if a drain will proceed or stall. |
| [Security](security/security.md) | Security posture overview — findings, hardening status, and entry into compliance / scanning / policies. |
| [Tenancy](security/tenancy.md) | Organise namespaces into tenants, see each tenant's namespace, CPU, and memory footprint, manage who belongs to a tenant, and track quota consumption per namespace. |
| [Users](security/users.md) | Shows who you are signed in as and what that identity may do, manages built-in local accounts, and issues revocable API tokens for automation. |

## Cost and FinOps

| Page | What it covers |
|------|----------------|
| [Budget Alerts](cost/budget-alerts.md) | Monthly spend budgets for the cluster, a tenant or a namespace. Budgets are stored and evaluated on the server from recorded cost history, and alerts go out through your notification channels once per threshold per month. Spend is an estimate from your configured unit prices, not an invoice. |
| [Chargeback](cost/chargeback.md) | Nav alias for namespace cost allocation / showback. There is no separate Chargeback UI — the link opens Cost Allocation. |
| [Cost Allocation](cost/cost-allocation.md) | Namespace-level chargeback view: estimated monthly cost rolled up by namespace, with CPU, memory, and storage share plus per-VM detail. |
| [Cost Estimator](cost/cost-estimator.md) | What-if cost calculator for planned VM fleets: adjust count, shape, and unit prices to estimate monthly and annual spend (labs-tier page). |
| [Cost Intelligence](cost/cost-intelligence.md) | Per-VM and per-namespace spend visibility, trends, and FinOps entry points. |
| [Costs](cost/costs.md) | Cluster cost dashboard: monthly spend trends, namespace and resource-type breakdowns, top expensive VMs, and optimization opportunities. |
| [Rightsizing](cost/rightsizing.md) | Recommendations for idle, oversized, or orphaned resources — turn Cost Intelligence into concrete shape changes. |
| [SLA Dashboard](cost/sla.md) | Live VM up/down posture plus configurable SLO targets (uptime % and latency). Historical uptime and error budget are not synthesized without availability history. |
| [Spot Savings](cost/spot-savings.md) | Nav alias for the Optimization Center. There is no separate Spot Savings page — the link opens resource optimization recommendations and savings tracking. |

## Insights, network, delivery and tools

| Page | What it covers |
|------|----------------|
| [AI Center](more/ai-center.md) | AI-assisted SRE, migration, and security advisors grounded in cluster evidence (Forge / built-in LLM when configured). |
| [Anomaly Detector](more/anomaly-detector.md) | Surfaces VM health, CPU, and memory outliers with risk levels and suggested next actions. The view auto-refreshes about every 10 seconds from live inventory and health scores. |
| [API Docs](more/api-docs.md) | Browsable REST reference for Zeus OS: live OpenAPI when available, plus categorized method/path descriptions for VMs, nodes, pods, and more. |
| [API Playground](more/api-playground.md) | In-browser HTTP client for Zeus OS REST endpoints: pick a method and path, send authenticated requests, and inspect status, headers, and body. |
| [ArgoCD](more/argocd.md) | Read-only dashboard of Argo CD Applications and Projects — sync and health status for GitOps workloads in the cluster. |
| [Auto-Remediation](more/auto-remediation.md) | Day-2 playbooks and policy controls that respond to common VM failures — crash loops, node pressure migrations, and advisory rightsizing or PVC expansion — with optional closed-loop autonomy. |
| [Catalog](more/catalog.md) | Infrastructure app catalog (Helm-oriented installs) for common day-2 stack pieces: browse categories, search apps, and trigger install. |
| [Chaos Engineering](more/chaos-engineering.md) | Controlled fault experiments against VMs — primarily kill virt-launcher pods to validate recovery; other stress types are listed when a fault-injection backend is available. |
| [CI/CD](more/cicd.md) | Pipeline inventory and run history with on-demand trigger controls for cluster-integrated CI/CD definitions. |
| [Cilium CNI](more/cilium.md) | Cilium status, endpoints, policies, Hubble packet flows, VM internet-egress controls, and a VM policy builder — when Cilium is installed in the cluster. |
| [Cluster Upgrade](more/cluster-upgrade.md) | Version awareness and an upgrade checklist for Kubernetes and KubeVirt — plus VLCM rollout controls — so operators plan upgrades without skipping critical backups and drains. |
| [Database Ops](more/database-ops.md) | Day-2 view of database instances and their backups — status, storage, endpoints, and connection details for operator copy-out. |
| [Debug](more/debug.md) | Host-level diagnostics for the Zeus OS node: live system stats, network interfaces, disk partitions, services, and a downloadable support bundle. |
| [Dependencies](more/dependencies.md) | Live graph of resource relationships — nodes, VMs, PVCs, Services, and labeled edges — so you can see what depends on what before a change. |
| [Deployment Strategies](more/deployment-strategies.md) | Define and run progressive delivery strategies (Rolling Update, Canary, Blue/Green, Recreate) against Kubernetes workloads, with execute and rollback controls. |
| [Disaster Recovery](more/disaster-recovery.md) | Disaster Recovery Center — visual DR plans, RPO/RTO targets, failover test scheduling, and step runbooks for day-2 resilience. |
| [DNS](more/dns.md) | Derived DNS / FQDN helpers for pods and VMs: search inventory, copy cluster-style names, and map IPs to names operators can use. |
| [GitOps](more/gitops.md) | Compare desired versus actual VM power state, show Flux/Argo cluster stats, and sync power-status drift back toward the intended running/stopped state. |
| [Helm Releases](more/helm.md) | List, install, upgrade history, rollback, and uninstall Helm releases, and manage chart repositories on the cluster. |
| [IaC](more/iac.md) | Infrastructure-as-code resource inventory with drift detection and a sync action for IaC-managed objects Zeus OS can see. |
| [Kernel Info](more/kernel.md) | Host hardware and OS inventory: hostname, kernel, CPU, BIOS, PCI devices, and memory modules for the Zeus OS node. |
| [Kustomize](more/kustomize.md) | Browse Kustomize bases and overlays, then preview the rendered diff before you apply changes outside the dashboard. |
| [Multi-Cluster](more/multi-cluster.md) | Multi-Cluster Command Center — list federation contexts, view the current cluster overview, and compare up to two clusters side by side. |
| [Network Flow](more/network-flow.md) | Zeus Network Center — service map, flows, DNS health, policies, and PacketWolf-backed containment actions, with Cilium/Hubble and cluster metrics as fallbacks when PacketWolf is offline. |
| [NLP Command](more/nlp-command.md) | Natural-language bar for VM power and lifecycle intents — parse plain English into a confirmed action before execution (labs tier). |
| [Operators](more/operators.md) | OLM inventory for ClusterServiceVersions, Subscriptions, OperatorGroups, CatalogSources, and InstallPlans with aggregate health stats. |
| [Optimization](more/optimization.md) | Resource optimization recommendations and estimated savings — review rightsizing suggestions and apply supported hotplug/shape changes when enabled. |
| [PacketWolf VM Guard](more/packetwolf.md) | Network intelligence and VM Shield containment — see allowed/denied flows and apply quarantine / internet-lock profiles (typically Cilium/Hubble backed). |
| [Performance Testing](more/perf-testing.md) | List and run performance tests defined in the cluster, with live metrics (users/pods tracked, estimated RPS, error rate, latency). |
| [Placement Advisor](more/placement-advisor.md) | Legacy nav entry for smart VM placement. The dashboard redirects this route to Placement, where node scoring and topology-manager recommendations live. |
| [Placement](more/placement.md) | Heuristic node scores from live topology, plus topology-manager API recommendations, so you can pick a suitable host for VM CPU/memory and affinity needs. |
| [Progressive Delivery](more/progressive-delivery.md) | Operate canary deployments and progressive rollouts — traffic weight, health signals, promote, and rollback — from one delivery dashboard. |
| [Resource Tags](more/resource-tagging.md) | Tag coverage and compliance for cluster resources: distribution of keys, untagged inventory, required-tag checks, and bulk apply. |
| [Mesh Detail](more/service-mesh-detail.md) | Legacy nav entry for service-mesh detail. The dashboard redirects this route to Service Mesh, the Multus NAD and VM attachment inventory. |
| [Status Page](more/status-page.md) | Operator-facing fleet status board: overall operational / degraded / outage banner, per-VM health, and recent Warning events. |
| [Terminal](more/terminal.md) | In-browser cluster shell: pick a pod/container, open an authenticated WebSocket session, and run commands with multi-tab support. |
| [Topology Mgr](more/topology-manager.md) | Node topology detail for NUMA zones, CPU pins, device allocations, and topology policies — deeper than the live map on Topology. |
| [Topology](more/topology.md) | Live map of infrastructure relationships — nodes, VMs, networks, and dependencies visualized. |
| [Webhook Tester](more/webhook-tester.md) | Validate alert webhook delivery: test configured alert webhooks or POST a custom payload to any URL and inspect latency and response. |
| [Widgets](more/widgets.md) | Customizable dashboard widget grid (VM count, capacity, health, events, favorites, alerts) with layout persistence in the browser. |

## Product centers and wizards

| Page | What it covers |
|------|----------------|
| [Application Center](centers/applications.md) | Group VMs into business applications with workspace scoping, health pulse, and an inspector for protection and membership. |
| [Approvals](centers/approvals.md) | Single inbox for decisions waiting on you — day-2 remediations pending approval and change requests. |
| [Auth audit log](centers/auth-audit.md) | Login and security event table sourced from `auth-audit.jsonl` on the Zeus OS data volume (`ZEUS_OS_DATA_DIR`). |
| [Backup & DR](centers/backup-dr.md) | Recovery Theatre hub — backup stats plus shortcuts to Velero, restore, snapshots, DR, and backup wizards. |
| [Console Sessions](centers/console-sessions.md) | Legacy route that redirects to ConsoleHub’s active sessions tab. Bookmarks and Settings links still resolve. |
| [Developer Center](centers/developer-center.md) | Operator and integrator hub for REST docs, API playground, CLI examples, webhooks, and plugin SDK entry points. |
| [Edge Center](centers/edge-center.md) | Guidance hub for branch clusters, air-gapped operation, and sync or compliance posture tied to multi-cluster views. |
| [Forge](centers/forge.md) | Native AI module hub — prompt handoff from AI Center, links to AI providers and GPU passthrough. Dedicated agent builder is not shipped on this page yet. |
| [Identity Center](centers/identity-center.md) | Landing hub for authentication and access governance — links to SSO, LDAP, MFA, Users & RBAC, auth audit, and API tokens. |
| [Machine Finder](centers/infra-browser.md) | Browse the datacenter → cluster → host → VM hierarchy, then jump into Machine Runway for fleet operations. |
| [Kubernetes Center](centers/kubernetes.md) | Hub for the container layer under your Zeus virtual datacenter — cluster pulse plus shortcuts to pods, services, nodes, and related day-2 tools. |
| [Marketplace](centers/marketplace.md) | Browse and deploy VM templates and blueprints — search, OS and category filters, favorites, AI draft assist, and a deploy wizard. |
| [Migration Command Center](centers/migration-factory.md) | VMware exit planning — migration waves, Transiva discovery handoff, preflight blockers, and wave readiness. Zeus OS does not perform VMware import itself. |
| [Cluster onboarding](centers/onboarding.md) | Guided preflight for a new Zeus OS cluster — platform readiness, Cilium status check, and cluster info — then links into core navigation. |
| [Patch Center](centers/patch-center.md) | Windows and Linux patch readiness across running VMs — risk signals, maintenance-window links, and compliance handoff. |
| [Plugins](centers/plugins.md) | Preview of partner and custom Zeus OS plugin categories. Install and uninstall are not available yet. |
| [Reports](centers/reports.md) | Executive and operational report catalog — shortcuts into health, protection, DR, security, network, cost, audit, and compliance exports. |
| [Restore Wizard](centers/restore-wizard.md) | Guided Velero restore — select a completed backup, configure target namespace and PV restore, then monitor restore phase to completion. |
| [Support](centers/support.md) | Operator support hub — download a redacted diagnostics bundle and jump to health, debug, API docs, audit, and terminal tools. |
| [Task Center](centers/tasks.md) | Long-running operations inbox — migrations, backups, and platform jobs with status, progress, and cancel when supported. |
| [Time Machine](centers/time-machine.md) | Cluster DVR and per-VM flight recorder — scrub recorded state over time. Frames come from the server-side sampler ring buffer. |
| [VM Groups](centers/vm-groups.md) | Label-based VM groups with bulk start, stop, and restart across matching members. |
| [War Room](centers/war-room.md) | Live incident assembly — active incident, affected VMs and nodes, recommended actions, pending remediations, and a warning-event feed in one place. |
| [Resource Canvas](centers/workspace.md) | Spatial map of compute, storage, networking, and AI entry points — click a node to open its window. |

## Settings

| Page | What it covers |
|------|----------------|
| [Settings — Advanced](settings/settings-advanced.md) | Shortcuts into platform, debug, and developer tooling, plus keyboard shortcuts and build information. |
| [Settings — AI providers](settings/settings-ai-providers.md) | Register and manage the language-model providers that power Zeus OS AI features, plus routing rules, API keys, stored memory, and the prompt library. |
| [Settings — API access](settings/settings-api-access.md) | Everything needed to automate against Zeus OS: scoped API tokens, the OpenAPI specification, rate-limit behaviour, and the FinOps change audit. |
| [Settings — Appearance](settings/settings-appearance.md) | Control how the Zeus OS shell looks and behaves: Light or Dark theme, wallpaper, glass and motion effects, sidebar mode, and the dock. |
| [Settings — Backup & DR](settings/settings-backup-dr.md) | Configuration entry points for Velero backups and disaster recovery, linking settings to the operational backup centers. |
| [Settings — General](settings/settings-general.md) | Server information and dashboard-wide preferences: what build you are running and how lists and cards behave for your account. |
| [Settings — Network](settings/settings-network.md) | Entry point for network-related configuration and the PacketWolf network-intelligence integration. |
| [Settings — Security](settings/settings-security.md) | Security-related configuration surfaced in the UI: active product edition, identity and SSO panels, browser console access policy, and a link into the security overview. |
| [Settings](settings/settings.md) | Configure the Zeus OS experience and platform integrations: general, appearance, network, security, backup/DR, AI providers, API access, and advanced options. |

---

157 guides. Regenerate this index with `node scripts/customer-docs/generate-guide-index.mjs`.

Capability-oriented reference (not page-oriented): [Feature Guide](../../zeus-os-customer-feature-guide.md).
