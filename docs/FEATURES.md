# Zeus OS features

Every feature in the current product, one by one: **146 features across 19 groups**. Features marked `Preview` or `Partial` have documented limits, stated in the row; unknown values are shown as unknown, never as zero.

- [1. VM Lifecycle & Fleet Operations](#vm-lifecycle--fleet-operations)
- [2. Consoles & Remote Access](#consoles--remote-access)
- [3. Networking & PacketWolf VM Shield](#networking--packetwolf-vm-shield)
- [4. Storage & Data](#storage--data)
- [5. Cost, FinOps & Optimization](#cost-finops--optimization)
- [6. Capacity, Autoscaling & Placement](#capacity-autoscaling--placement)
- [7. Observability, Topology & Time Machine](#observability-topology--time-machine)
- [8. Security Posture & Vulnerability](#security-posture--vulnerability)
- [9. Compliance, Governance & Admission Control](#compliance-governance--admission-control)
- [10. Day-2 Automation & Remediation](#day-2-automation--remediation)
- [11. Incident Response & War Room](#incident-response--war-room)
- [12. GitOps, CI/CD & Change Management](#gitops-cicd--change-management)
- [13. Backup, DR & Snapshots](#backup-dr--snapshots)
- [14. Multi-Cluster, Multi-Tenancy & Enterprise Identity](#multi-cluster-multi-tenancy--enterprise-identity)
- [15. AI Ops, Marketplace & Developer Center](#ai-ops-marketplace--developer-center)
- [16. Edge, Chaos, Performance & Platform Ops](#edge-chaos-performance--platform-ops)
- [Also included](#also-included)

## 1. VM Lifecycle & Fleet Operations

_Create, run, migrate, and manage KubeVirt virtual machines at fleet scale without touching kubectl._

| Feature | What it does |
|---|---|
| **VM Command Center** | Browse, filter, and operate every KubeVirt VM and running instance from one inventory with power, pause, restart, and detail drill-down. |
| **VM Workbench & Power Actions** | Start, stop, restart, pause, and delete VMs from a dedicated workbench separated from read-only browse views. |
| **VM Setup & Template Wizard** | Guided creation from instance types, preferences, and templates with cluster-grounded, AI-assisted manifest generation. |
| **Templates & Instance Type Catalog** | Curated VM templates, KubeVirt instance types, and preferences browsable and one-click deployable. |
| **Hot-Plug CPU, Memory & Disks** | Add vCPU, RAM, and data disks to running VMs live without a reboot. |
| **NIC Model Selection** | Choose VirtIO or e1000e per network interface, at creation or on an existing VM. |
| **Virtual Devices & Memory Overcommit** | Toggle watchdog, VirtIO RNG, sound, USB tablet, serial console, and the virtio memory-balloon device per VM. |
| **Live Migration Assistant** `Preview` | Plan and start live VM migrations with a guided wizard. Some pre-checks are estimates and the target node is not yet passed to KubeVirt. |
| **Migration Factory** `Partial` | Batch-migrate and convert VMs, including disk conversion, across nodes and storage as a supervised campaign. Cross-cluster migration is not implemented yet. |
| **VM Groups & Fleet Bulk Ops** | Organize VMs into logical groups and apply power, tagging, and lifecycle actions in bulk. |
| **VM Clone & Compare** | Clone VMs from running state or snapshots and diff two VMs' configuration side by side. |
| **VM Health & Repair** | Per-VM health scoring plus guided repair actions for stuck, unschedulable, or degraded instances. |
| **Windows Enterprise & Licensing** | Windows guest customization, sysprep, and license tracking for Windows VM estates. |
| **Windows via Kryton** | Optional Kryton REST catalog for Windows create + golden factory (12 dockur IDs); Zeus keeps day-2 VNC/native RDP/GuestKit. |
| **Guest Intelligence** | Reads guest-agent data for OS, IPs, installed software, and in-guest state. |

## 2. Consoles & Remote Access

_Live VNC, serial, terminal, RDP, and SSH access with real-time metrics — all in the browser._

| Feature | What it does |
|---|---|
| **VNC Graphical Console** | Full graphical VM console streamed over WebSocket, including a pop-out standalone window. |
| **Serial Console** | Live serial-port console for headless VMs and boot-time troubleshooting. |
| **Native RDP & SSH (NodePort expose)** | One-click expose of RDP or SSH over a NodePort (a free port is assigned and collisions are rejected), then connect with your own client using a downloadable .rdp file or an ssh command. |
| **Console Hub & Workspace** | Multi-console workspace with tabs, session management, and a unified console launcher. |
| **Live Console Metrics** | Real-time CPU, memory, disk, and network telemetry streamed alongside each console. |
| **Console Session Recording & Sharing** | Record, replay, and share console sessions for training, audit, and collaboration. |
| **In-Browser Terminal** | Cluster and pod terminal access with WebSocket-backed shells. |

## 3. Networking & PacketWolf VM Shield

_See exactly what a VM talks to and contain it in one click — kernel-native visibility and enforcement._

| Feature | What it does |
|---|---|
| **PacketWolf VM Shield** | Unified per-VM network visibility and one-click containment with desired-vs-actual verification and a background reconciler. |
| **Live Flow Watch (Hubble)** | Streams a VM's live allowed/denied flows, dependency map, public-exposure findings, and an explainable risk score. |
| **Containment Profiles** | Internet lock, full quarantine, lateral lock, exfiltration lock, and investigation mode — with optional termination of existing connections. |
| **Policy Preview & Dry-Run** | Dry-runs the exact containment policy against recorded traffic to show what it will and won't break. |
| **Per-VM Firewall & Egress Control** | Block specific outbound ports (SMB, RDP, C2) and manage per-VM firewall rules from a panel. |
| **Cilium Dashboard** | Visualize Cilium identities, endpoints, and network policy enforcement across the cluster. |
| **Network Policy Builder** | Visually author, simulate, and apply Kubernetes and Cilium network policies. |
| **Network Flow & Observability** | Cluster-wide network flow maps, attachments (Multus), and traffic observability. |
| **Service Mesh & Ingress** | Manage service mesh routing, ingress rules, service discovery, and full MetalLB IPAddressPool/L2Advertisement CRUD (create and delete pools, not just view). |
| **VM-Aware Ingress** | Create, validate, and delete Ingress rules for a VM's exposed Service directly from the VM inspector, with TLS-secret and host-conflict checks before you apply. |
| **Host Networking (NMState)** | Declare NIC/bond/VLAN configuration for cluster nodes and see per-node apply status, via the kubernetes-nmstate operator. |
| **DNS & IPAM** | Cluster DNS records and IP address management for VMs and services. |

## 4. Storage & Data

_Manage DataVolumes, disks, PVCs, images, and storage migration for the whole VM estate._

| Feature | What it does |
|---|---|
| **Storage Explorer** | Unified view of storage classes, PVCs, volumes, and capacity across the cluster. |
| **DataVolumes & CDI Import** | Create and import DataVolumes from URLs, registries, and uploads via the CDI upload flow. |
| **Disk Manager & Hot-Plug** | Add, resize, and hot-plug VM disks including live PVC resize. |
| **Image Library, Factory & Registry** | Curate boot images, build images with the Image Factory (Zeus ISO pipelines and optional **Build with Kryton**), and browse the image registry. |
| **Storage Migration** | Move VM volumes between storage classes and backends with supervised migration. |
| **Volume Snapshots** | Point-in-time volume snapshots integrated with the snapshot manager. |
| **Storage Intelligence** | Analytics on storage usage, waste, and growth trends with optimization hints. |
| **Atlas Distributed Storage** | Read-only Ceph/NFS backend, cluster, and pool inventory proxied from Atlas (the Zyvor storage control plane), surfaced on the Storage page. |

## 5. Cost, FinOps & Optimization

_Per-VM cost visibility, waste detection, forecasting, chargeback, and rightsizing._

| Feature | What it does |
|---|---|
| **Cost Intelligence Dashboard** `Partial` | Per-VM and per-namespace cost from a price model you configure, with trends and drill-down. A model, not billing data. |
| **Chargeback & Cost Allocation** | Allocate spend to tenants, teams, and projects with a chargeback engine and reports. |
| **Waste Detection & Rightsizing** | Finds idle, oversized, and orphaned resources and recommends right-sized shapes. |
| **Cost Forecasting** | Projects future spend from usage trends and growth models. |
| **Budget Alerts** | Server-side monthly budgets per cluster, tenant or namespace, evaluated from recorded cost history, with one alert per threshold per month through your notification channels. Estimates from configured unit prices, not invoices. |
| **Spot & Savings Advisor** | Identifies spot and savings-plan opportunities for eligible workloads. |
| **Optimization Center** | Consolidated hub of cost, capacity, and performance optimization recommendations. |
| **Cost Estimator** | Pre-deployment cost estimation for planned VMs and workloads. |

## 6. Capacity, Autoscaling & Placement

_Plan headroom, schedule smartly, and scale nodes, pods, and VMs automatically._

| Feature | What it does |
|---|---|
| **Capacity Planning** | Cluster and node capacity dashboards with headroom, saturation, and what-if analysis. |
| **Cluster Autoscaling** | Configure and observe node autoscaling behavior and scale events. |
| **HPA & VPA Managers** | Manage Horizontal and Vertical Pod Autoscalers with recommendations. |
| **Placement Advisor** | Recommends optimal nodes for VMs using affinity, taints, and resource fit. |
| **Affinity, Taints & Tolerations** | Author affinity/anti-affinity rules, node taints, and tolerations visually. |
| **Priority & Runtime Classes** | Manage PriorityClasses, RuntimeClasses, and Pod Disruption Budgets. |
| **Utilization Heatmap** | Cluster-wide heatmap of resource pressure across nodes and namespaces. |
| **Node & HA/DRS Management** | Node inventory, cordon/drain, and HA/DRS workload balancing, from suggest-only to fully automated, with a per-VM cooldown against thrashing and a full history of what the engine moved and why. |
| **Manual Node Fencing** | Force-remediate a node you have confirmed dead out of band: cordon it and force-delete its VM instances so KubeVirt reschedules them elsewhere. Needs an explicit opt-in and a "node is dead" confirmation, and refuses on any node still reporting Ready. |
| **GPU & Device Plugins** | Manage GPU dashboards, device plugins, and hardware device attachment, including a vGPU mediated-device profile picker with a manual-resource fallback when no GPU hardware is present. |

## 7. Observability, Topology & Time Machine

_Topology maps, distributed tracing, logs, metrics, and point-in-time cluster history._

| Feature | What it does |
|---|---|
| **Topology & Dependency Graph** | Interactive maps of nodes, VMs, pods, services, and their dependencies. |
| **Cluster DVR & VM Flight Recorder** | Time Machine that continuously samples cluster and per-VM state for point-in-time replay. |
| **Distributed Tracing & APM** `Partial` | Service list, request rate and error rate from PacketWolf flows. Latency percentiles are shown only when measured, otherwise unknown. |
| **Logs Explorer & Aggregation** | Centralized log search and aggregation across pods and VMs. |
| **Metrics & Custom Metrics** | Real Prometheus-backed metrics, custom metric dashboards, and monitoring targets. |
| **Anomaly Detection** | Detects abnormal resource, cost, and behavior patterns automatically. |
| **Timeline & Gantt View** `Partial` | Chronological timeline of events and remediation actions, and Gantt-style operation views. |
| **Event Analysis** | Correlates and analyzes Kubernetes events for root-cause signals. |
| **System Health & Status Page** | Overall cluster health scoring and a shareable status page. |

## 8. Security Posture & Vulnerability

_Continuous posture scoring, image scanning, secrets, and a dedicated security operations center._

| Feature | What it does |
|---|---|
| **Security Posture & Overview** | Continuous scoring of cluster and VM security posture with prioritized findings. |
| **Vulnerability & Image Scanning** | Scans container and VM images for CVEs with severity breakdowns. |
| **Security Operations Center** | Consolidated SecOps view of threats, containment actions, and response state. |
| **Secrets & External Secrets** | Manage Kubernetes secrets and External Secrets Operator integrations. |
| **Certificate Manager** | Track, issue, and rotate TLS certificates across the cluster. |
| **eBPF & Kernel Intelligence** | Kernel-level (eBPF) runtime signals and kernel info for deep security context. |
| **Patch Center** `Partial` | Patch readiness checks and patch planning. Zeus OS does not execute patches yet. |

## 9. Compliance, Governance & Admission Control

_Frameworks, policy engines, admission webhooks, and RBAC visualization for provable control._

| Feature | What it does |
|---|---|
| **Compliance & Frameworks** | Continuous compliance checks mapped to frameworks with pass/fail evidence. |
| **OPA Gatekeeper & Zeus Policies** | Manage OPA Gatekeeper constraints and native Zeus policy definitions. |
| **Admission Control** | Configure admission webhooks and validate resources before they're admitted. |
| **Policy Simulation & Violations** | Simulate policy impact and track live policy violations. |
| **RBAC Visualizer** | Visual map of roles, bindings, service accounts, and effective permissions. |
| **Audit Log & Trail** | Immutable audit trail of every action across surfaces. |
| **Resource Governance & Quotas** | Resource quotas, limits, and governance policy across namespaces and tenants. |
| **Resource Tagging** | Consistent tagging and labeling for ownership, cost, and policy. |

## 10. Day-2 Automation & Remediation

_Closed-loop remediation, scheduled operations, workflows, and macros that run the boring parts._

| Feature | What it does |
|---|---|
| **Day-2 Closed-Loop Remediation** | Background engine that detects signals and runs remediation playbooks with a kill-switch. |
| **Auto-Remediation Playbooks** | Registry of remediation playbooks with signal-to-action mapping and audit. |
| **Scheduled Operations** | Schedule power on/off, snapshots, and other operations on cron-like cadences. |
| **Workflow Automation & Manager** | Compose multi-step operational workflows across resources. |
| **Macros & Batch Actions** `Preview` | Bulk operations across many resources. Macro recording and replay is not yet available. |
| **Task Center** | Central queue of running, scheduled, and completed operational tasks. |
| **Undo & Rollback** | Rollback and undo support for reversible operations. |

## 11. Incident Response & War Room

_Auto-assembled war rooms, guided response wizards, RCA, and SLA/SLO tracking._

| Feature | What it does |
|---|---|
| **Incident Center** | Track active incidents with severity, timeline, and correlated context. |
| **War Room Auto-Assembly** | Automatically assembles topology, logs, metrics, and RCA context for an active incident. |
| **Incident Response Wizard** | Guided, step-by-step response flows with recommended remediation. |
| **Incident Chat** | In-context collaboration thread tied to an incident. |
| **SLA Dashboard & SLO Manager** | Define and track SLOs, error budgets, and SLA compliance. |
| **Alerting & Notifications** | Alert rules, Prometheus rules, notification routing, and an alerting engine. |
| **Executive Briefing** | Auto-generated briefings summarizing state, risk, and incidents for leadership. |

## 12. GitOps, CI/CD & Change Management

_Argo/Flux sync, Helm and Kustomize, progressive delivery, and gated change approval._

| Feature | What it does |
|---|---|
| **GitOps Sync (Argo/Flux)** `Partial` | Read-only view of Flux and Argo CD sync state and drift for objects that already exist in the cluster. |
| **Helm & Kustomize** | Browse and manage Helm releases and Kustomize overlays. |
| **Progressive Delivery** | Canary, blue-green, and progressive rollout strategies with health gating. |
| **CI/CD Pipelines** | View and integrate CI/CD pipeline status for delivered workloads. |
| **Change Approval & Approvals** | Gate risky changes behind approval workflows before they execute. |
| **Infrastructure as Code** | Manage IaC definitions and environment configuration for the estate. |
| **Environment Management** | Model and manage dev/stage/prod environments and promotion. |

## 13. Backup, DR & Snapshots

_Velero-backed backups, disaster recovery orchestration, and scheduled VM snapshots._

| Feature | What it does |
|---|---|
| **Backup & DR Center** | Configure and monitor VM/cluster backups with a guided backup wizard. |
| **Velero Integration** | Native Velero backup and restore management for Kubernetes and VM resources. |
| **Disaster Recovery Orchestration** `Partial` | DR plans with measured RPO and a real restore test into a scratch namespace. Failover and execute steps are simulated and labelled as such. |
| **Snapshot Manager & Scheduling** | Take, browse, and restore VM snapshots on demand or on a schedule. |
| **Restore Wizard** | Guided restore of VMs and volumes from backups and snapshots. |

## 14. Multi-Cluster, Multi-Tenancy & Enterprise Identity

_Fleet-wide operations, tenant isolation, OIDC/LDAP/SAML/MFA, API tokens, and SIEM._

| Feature | What it does |
|---|---|
| **Multi-Cluster Fleet** `Partial` | Register remote clusters, connect, probe health and compare counts per cluster. Moving VMs between clusters is not implemented yet. |
| **Multi-Tenancy** | Namespace-label-based tenant isolation with per-tenant filtering across views. |
| **Enterprise SSO (OIDC/LDAP/SAML)** | Pluggable authentication with OIDC, LDAP, SAML, and local modes; local admin stays available as an automatic break-glass fallback whenever SSO is active. Verified live against a real Keycloak realm. |
| **Identity Center & User Management** | Manage users, roles, sessions, and identity policy with session revocation. |
| **API Tokens & Scoped Access** | Issue scoped API keys and bearer tokens for automation and integrations. |
| **SIEM & Auth Audit** | Stream auth and audit events to SIEM systems with a dedicated auth-audit view. |
| **Log Shipping** | Forward virt-launcher pod logs to Loki or a generic HTTP endpoint, filterable by namespace or VM, with no in-cluster collection agent. |
| **Provider Portal** | Multi-tenant provider/operator portal for managed-service delivery. |

## 15. AI Ops, Marketplace & Developer Center

_Built-in evidence-first LLM, copilots, blueprints, marketplace, and a developer toolkit._

| Feature | What it does |
|---|---|
| **AI Center & Copilot** | Built-in LLM (in-cluster Ollama or Forge gateway) for evidence-first, auditable assistance. |
| **Autonomous AI Ops** | AI-driven analysis, troubleshooting, and recommendation generation grounded in live cluster state. |
| **Natural-Language Command & Search** | NLP-driven command bar and universal search across the estate. |
| **RAG Template Catalog** | Retrieval-augmented generation over the template catalog using Qdrant and local embeddings. |
| **Marketplace & Blueprints** | Browse and deploy application blueprints and marketplace workspaces. |
| **Application & Service Catalog** | Curated catalog of applications, operators, and services to deploy. |
| **Developer Center & Playground** | API docs, API playground, GraphQL, webhook tester, and debug tools. |
| **Plugins & Custom Resources** | Extend Zeus OS with plugins and manage arbitrary Kubernetes custom resources. |

## 16. Edge, Chaos, Performance & Platform Ops

_Edge fleets, chaos experiments, performance testing, database ops, and cluster lifecycle._

| Feature | What it does |
|---|---|
| **Edge Center** | Manage distributed edge clusters and remote-site workloads. |
| **Chaos Engineering** | Design and run fault-injection experiments to test resilience. |
| **Performance Testing & Profiling** | Load, performance testing, and profiling for workloads and VMs. |
| **Database Operations** | Manage database workloads and operators from a dedicated DB ops surface. |
| **Operators Hub** | Discover, install, and manage Kubernetes operators. |
| **Cluster Upgrade & Lifecycle** `Partial` | Upgrade pre-checks and version-skew rules for cluster and node upgrades. Zeus OS does not execute upgrades yet. |
| **Host & Hypervisor Management** | Inspect and manage physical hosts, host groups, and hypervisor state. |
| **Reports & Analytics** | Generate exportable reports across cost, compliance, capacity, and security. |

## Also included

### Identity and provisioning

| Feature | What it does |
|---|---|
| **SCIM v2 provisioning** | Provision users and groups from your identity provider, with group-to-role mapping and deactivation honoured at sign-in. |
| **WebAuthn second factor** | Hardware security keys as a second factor for local sign-in. |
| **Email and chat notification channels** | SMTP email, Slack, Teams, webhook and PagerDuty channels with masked configuration and SSRF guards. |

### Platform

| Feature | What it does |
|---|---|
| **Plugin registry** | Register plugins with HMAC-signed webhooks and navigation entries. |
| **Content library** | Subscribe to signed template bundles; imports always land as unapproved drafts. |
| **Zeus state backup and restore** | Back up and restore Zeus OS state; secrets are excluded unless you supply a passphrase. |
| **Maintenance windows** | Define maintenance windows. |
| **Zyra knowledge index** | Ask Zyra over your own repositories with retrieval and citations; off by default for remote models. |
| **English and Spanish interface** | Light and dark appearance, a command palette, and accessibility checks in CI. The Spanish translation is machine-drafted. |

### Networking extras

| Feature | What it does |
|---|---|
| **Cilium egress gateway, BGP and Gateway API** | Manage egress gateway policies, BGP peering, L2 announcements and Gateway API resources. |
| **Cilium encryption status** | Read-only WireGuard encryption status. |
| **Netra integration** | Typed views over Netra observation, with leased emergency deny that needs a platform admin. |
