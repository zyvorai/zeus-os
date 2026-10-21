# Zeus OS — Complete page index

Every navigable dashboard page from `ui/src/navigation/navConfig.ts`.
Deep how-to guides exist for primary journeys under [`pages/`](pages/README.md);
this index covers the **full catalog** (including labs/integrate-tier screens).

_Generated: 2026-10-21 · 135 pages_

Regenerate: `node scripts/customer-docs/generate-page-index.mjs`

## Observe

| Page | Route | Purpose | Guide |
|------|-------|---------|-------|
| System Health | `/system-health` | Platform component health dashboard. | [Open](pages/observe/system-health.md) |
| Host Info | `/host` | Host / control host information. | [Open](pages/observe/host.md) |
| Monitoring Targets | `/monitoring` | Prometheus/monitoring scrape targets. | [Open](pages/observe/monitoring.md) |
| VM Monitor | `/vm-monitor` | Per-VM health scoring and repair entry. | [Open](pages/observe/vm-monitor.md) |
| Capacity | `/capacity` | Cluster capacity planning views. | [Open](pages/observe/capacity.md) |
| Resource Heatmap | `/heatmap` | Resource utilization heatmap. | [Open](pages/observe/heatmap.md) |
| Events | `/events` | Kubernetes and platform events stream. | [Open](pages/observe/events.md) |
| APM | `/apm` | Application performance monitoring dashboard. | [Open](pages/observe/apm.md) |
| Custom Metrics | `/custom-metrics` | Custom metrics browser. | [Open](pages/observe/custom-metrics.md) |
| Alerting | `/alerting` | Alert rules and firing alerts. | [Open](pages/observe/alerting.md) |
| Logs Explorer | `/logs-explorer` | Log search and exploration. | [Open](pages/observe/logs-explorer.md) |
| SLO Manager | `/slo-manager` | SLO definitions and burn-rate views. | [Open](pages/observe/slo-manager.md) |
| Incident chat | `/incident-chat` | Collaborative incident chat (labs). | [Open](pages/observe/incident-chat.md) |
| Ask Zyra | `/ask-zyra` | Operator page **Ask Zyra** at `/ask-zyra` — open from the sidebar or command palette. | — |
| AI Center | `/ai-center` | Operator page **AI Center** at `/ai-center` — open from the sidebar or command palette. | [Open](pages/more/ai-center.md) |
| Forge (AI) | `/forge` | Operator page **Forge (AI)** at `/forge` — open from the sidebar or command palette. | [Open](pages/centers/forge.md) |
| GPU Devices | `/gpu` | GPU device inventory for accelerated VMs. | [Open](pages/cluster/gpu.md) |
| Anomaly Detector | `/anomaly-detector` | Metric and behavior anomaly detection. | [Open](pages/more/anomaly-detector.md) |
| Auto-Remediation | `/auto-remediation` | Day-2 auto-remediation playbooks. | [Open](pages/more/auto-remediation.md) |
| NLP Command | `/nlp-command` | Natural-language command bar (labs). | [Open](pages/more/nlp-command.md) |
| Costs | `/costs` | Cost overview dashboard. | [Open](pages/cost/costs.md) |
| Cost Intelligence | `/cost-intelligence` | Per-VM / namespace spend and trends. | [Open](pages/cost/cost-intelligence.md) |
| Cost Allocation | `/cost-allocation` | Cost allocation by team or label. | [Open](pages/cost/cost-allocation.md) |
| Cost Estimator | `/cost-estimator` | What-if cost estimator (labs). | [Open](pages/cost/cost-estimator.md) |
| Budget Alerts | `/budget-alerts` | Budget thresholds and alerts. | [Open](pages/cost/budget-alerts.md) |
| Forecasting | `/forecasting` | Capacity and demand forecasting. | [Open](pages/observe/forecasting.md) |
| SLA Dashboard | `/sla` | SLA dashboard and breach tracking. | [Open](pages/cost/sla.md) |
| Optimization | `/optimization` | Optimization center recommendations. | [Open](pages/more/optimization.md) |

## Security

| Page | Route | Purpose | Guide |
|------|-------|---------|-------|
| Security | `/security` | Security posture overview. | [Open](pages/security/security.md) |
| Security operations | `/security?tab=operations` | Operator page **Security operations** at `/security?tab=operations` — open from the sidebar or command palette. | — |
| Compliance | `/compliance` | Compliance checks and evidence. | [Open](pages/security/compliance.md) |
| Compliance frameworks | `/compliance?tab=frameworks` | Operator page **Compliance frameworks** at `/compliance?tab=frameworks` — open from the sidebar or command palette. | — |
| Certificates | `/certificates` | Certificate inventory and expiry. | [Open](pages/security/certificates.md) |
| Change Approval | `/change-approval` | Gated change approval queue. | [Open](pages/security/change-approval.md) |
| OPA Gatekeeper | `/opa` | OPA/Gatekeeper constraint overview. | [Open](pages/security/opa.md) |
| Admission Control | `/admission-control` | Admission policy controls. | [Open](pages/security/admission-control.md) |
| Image Scanning | `/image-scanning` | Vulnerability image scan results. | [Open](pages/security/image-scanning.md) |
| External Secrets | `/external-secrets` | External Secrets Operator resources. | [Open](pages/security/external-secrets.md) |
| Policies | `/cloudos-policies` | Operator page **Policies** at `/cloudos-policies` — open from the sidebar or command palette. | — |
| CI/CD | `/cicd` | CI/CD pipeline views (integrate). | [Open](pages/more/cicd.md) |
| GitOps | `/gitops` | GitOps sync status (integrate). | [Open](pages/more/gitops.md) |
| ArgoCD | `/argocd` | Argo CD application overview (integrate). | [Open](pages/more/argocd.md) |
| Kustomize | `/kustomize` | Kustomize overlays dashboard (integrate). | [Open](pages/more/kustomize.md) |
| IaC | `/iac` | Infrastructure-as-code integrations. | [Open](pages/more/iac.md) |
| Helm Releases | `/helm` | Helm release inventory. | [Open](pages/more/helm.md) |
| Progressive Delivery | `/progressive-delivery` | Canary/blue-green progressive delivery. | [Open](pages/more/progressive-delivery.md) |
| Deployment Strategies | `/deployment-strategies` | Deployment strategy catalog. | [Open](pages/more/deployment-strategies.md) |
| Catalog | `/catalog` | Service / VM catalog browser. | [Open](pages/more/catalog.md) |
| Marketplace | `/marketplace` | Operator page **Marketplace** at `/marketplace` — open from the sidebar or command palette. | [Open](pages/centers/marketplace.md) |
| Automation | `/shortcuts` | Operator page **Automation** at `/shortcuts` — open from the sidebar or command palette. | — |
| Workflows | `/workflows` | Automation workflow manager. | [Open](pages/run/workflows.md) |
| Chaos Engineering | `/chaos-engineering` | Chaos experiments and safety rails. | [Open](pages/more/chaos-engineering.md) |
| Performance Testing | `/perf-testing` | Performance testing campaigns. | [Open](pages/more/perf-testing.md) |
| Database Ops | `/database-ops` | Database operations helpers. | [Open](pages/more/database-ops.md) |
| Developer Center | `/developer-center` | Operator page **Developer Center** at `/developer-center` — open from the sidebar or command palette. | [Open](pages/centers/developer-center.md) |
| API Docs | `/api-docs` | OpenAPI / API documentation for /api/v1. | [Open](pages/more/api-docs.md) |
| API Playground | `/api-playground` | Interactive REST API playground. | [Open](pages/more/api-playground.md) |
| Webhook Tester | `/webhook-tester` | Test outbound webhooks. | [Open](pages/more/webhook-tester.md) |
| Terminal | `/terminal` | In-browser cluster/pod terminal over WebSocket. | [Open](pages/more/terminal.md) |
| Plugins | `/plugins` | Operator page **Plugins** at `/plugins` — open from the sidebar or command palette. | [Open](pages/centers/plugins.md) |
| Resource Canvas | `/workspace` | Operator page **Resource Canvas** at `/workspace` — open from the sidebar or command palette. | [Open](pages/centers/workspace.md) |
| Widgets | `/widgets` | Customizable dashboard widgets. | [Open](pages/more/widgets.md) |
| Debug | `/debug` | Debug tools for support cases. | [Open](pages/more/debug.md) |
| Kernel Info | `/kernel` | Kernel / node kernel information. | [Open](pages/more/kernel.md) |
| Settings | `/settings` | Configure appearance, security, backup/DR, AI providers, and API access. | [Open](pages/settings/settings.md) |
| Identity Center | `/identity-center` | Operator page **Identity Center** at `/identity-center` — open from the sidebar or command palette. | [Open](pages/centers/identity-center.md) |
| Users | `/identity-center?tab=users` | Operator page **Users** at `/identity-center?tab=users` — open from the sidebar or command palette. | — |
| Auth Audit | `/identity-center?tab=review` | Operator page **Auth Audit** at `/identity-center?tab=review` — open from the sidebar or command palette. | — |
| Tenancy | `/tenancy` | Multi-tenant namespace scoping. | [Open](pages/security/tenancy.md) |
| Multi-Cluster | `/multi-cluster` | Multi-cluster fleet registration. | [Open](pages/more/multi-cluster.md) |
| Edge Center | `/edge-center` | Operator page **Edge Center** at `/edge-center` — open from the sidebar or command palette. | [Open](pages/centers/edge-center.md) |
| Provider Portal | `/provider-portal` | Operator page **Provider Portal** at `/provider-portal` — open from the sidebar or command palette. | — |
| Status Page | `/status-page` | Public/internal status page builder. | [Open](pages/more/status-page.md) |
| Support | `/support` | Operator page **Support** at `/support` — open from the sidebar or command palette. | [Open](pages/centers/support.md) |

## Workbench, wizards & centers (routed, not always in nav)

| Page | Route | Purpose | Guide |
|------|-------|---------|-------|
| VM workbench | `/vms/:namespace/:name` | Power, console, hardware, guest ops for one VM | [Open](pages/core/vm-workbench.md) |
| Create machine | `/vms/new` | Create VM wizard alias | [Open](pages/core/vm-setup.md) |
| Consoles overview | `(from workbench)` | VNC, serial, RDP/SSH | [Open](pages/consoles/overview.md) |
| ConsoleHub | `/consolehub` | Multi-console launcher and session manager | [Open](pages/consoles/consolehub.md) |
| Console Sessions | `/console-sessions` | Session list (opens ConsoleHub sessions tab) | [Open](pages/centers/console-sessions.md) |
| Restore Wizard | `/restore-wizard` | Guided restore from snapshot/backup | [Open](pages/centers/restore-wizard.md) |
| Onboarding | `/onboarding` | First-run wizard | [Open](pages/centers/onboarding.md) |
| Atlas | `/atlas` | Hierarchical infrastructure browser | — |
| Applications | `/applications` | Application-centric workload view | [Open](pages/centers/applications.md) |
| Kubernetes | `/kubernetes` | Cluster pulse center (edition-gated) | [Open](pages/centers/kubernetes.md) |
| VM Groups | `/vm-groups` | Logical VM cohorts and bulk operations | [Open](pages/centers/vm-groups.md) |
| AI Center | `/ai-center` | AI SRE / advisors | [Open](pages/more/ai-center.md) |
| Identity Center | `/identity-center` | SSO, MFA, access reviews | [Open](pages/centers/identity-center.md) |
| Developer Center | `/developer-center` | API, CLI, Terraform, webhooks | [Open](pages/centers/developer-center.md) |
| Backup / DR | `/backup-dr` | Backup and DR center | [Open](pages/centers/backup-dr.md) |
| Migration Factory | `/migration-factory` | Batch migration campaigns (links out to Transiva/h2kvm) | [Open](pages/centers/migration-factory.md) |
| Edge Center | `/edge-center` | Edge fleet overview | [Open](pages/centers/edge-center.md) |
| Patch Center | `/patch-center` | Guest patch status and campaigns | [Open](pages/centers/patch-center.md) |
| Marketplace | `/marketplace` | Deployable content marketplace | [Open](pages/centers/marketplace.md) |
| Plugins | `/plugins` | Plugin catalog (preview) | [Open](pages/centers/plugins.md) |
| Forge | `/forge` | AI infrastructure workspace | [Open](pages/centers/forge.md) |
| Workspace | `/workspace` | Infinite canvas multi-console workspace | [Open](pages/centers/workspace.md) |
| Machine Firewall | `/network-flow?tab=firewall` | Host and VM firewall posture | — |
| War Room | `/war-room` | Collaborative incident response surface | [Open](pages/centers/war-room.md) |
| Time Machine | `/time-machine` | Cluster DVR / point-in-time flight recorder | [Open](pages/centers/time-machine.md) |
| Approvals | `/approvals` | Pending action approval queue | [Open](pages/centers/approvals.md) |
| Reports | `/reports` | Reports and exports center | [Open](pages/centers/reports.md) |
| Task Center | `/tasks` | Long-running task tracking | [Open](pages/centers/tasks.md) |
| Support | `/support` | Support bundle and help | [Open](pages/centers/support.md) |
| Auth Audit | `/auth-audit` | Authentication audit trail | [Open](pages/centers/auth-audit.md) |
| Security Operations | `/security?tab=operations` | Security operations hub | — |

## Related

- [Customer docs home](README.md)
- [Page-by-page guides](pages/README.md)
- [Feature Guide](../zeus-os-customer-feature-guide.md)
