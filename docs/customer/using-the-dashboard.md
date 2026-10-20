# Using the Dashboard

How the Zeus OS web shell works — so page guides make sense.

## Surfaces inside the browser

| Element | Purpose |
|---------|---------|
| **Home / Mission Control** | Chapter home + highlights band + Attention teaser |
| **Sidebar / Finder tree** | Primary navigation by product center |
| **Workspace switcher** | Quick jump: Dashboard, VMs, Kubernetes, AI, Storage, Monitoring |
| **Command palette** | Search any page or action by name |
| **Top bar** | Context (cluster/namespace), quick links (Settings, Terminal, API Docs) |
| **Inspector / sheets** | Detail panels without leaving the list |
| **Workbench routes** | Full-page ops for a single VM or object |

## Browse vs workbench (important)

Zeus separates **inventory** from **actions**:

- **Browse** (`/vms`, `/pods`, `/nodes`, …) — read, filter, compare, open details.
- **Workbench** (`/vms/:namespace/:name`, hardware studio, consoles) — start/stop, hot-plug, remote access, guest agent.

That design reduces accidental power actions on production fleets.

## Finding any page

1. Sidebar section (Core, Cluster, Observe, Run, Security, Cost, More).
2. Command palette — type “packetwolf”, “velero”, “cost”, etc.
3. This manual’s [PAGE_INDEX.md](PAGE_INDEX.md) — every route with a one-line purpose.
4. Favorites (`/favorites`) — pin pages you use daily.

Every page guide includes **Operate from the console (UX)** — concrete clicks after you land on the route.

## Namespaces and tenancy

Lists usually respect the active namespace filter (and tenant scope if multi-tenancy is enabled). If a VM “disappeared”:

1. Clear or broaden the namespace filter.
2. Confirm you are in the correct tenant (Identity / Tenancy).
3. Refresh — live watches may lag briefly after create/delete.

## Consoles

| Method | Where | Notes |
|--------|-------|-------|
| VNC | VM workbench / ConsoleHub | HTTPS required |
| Serial | VM workbench | Works over HTTP or HTTPS |
| RDP / SSH | Remote access panel | Native OS client via NodePort |
| Multi-session | `/consolehub`, `/workspace` | Tabs and session policy |

## Keyboard and accessibility

- Command palette: ⌘K / Ctrl+K (exact binding shown in the shell).
- Escape closes sheets and overlays.
- Focus traps exist on modals — tab stays inside the dialog.

## Settings you may need early

| Setting area | Path | Why |
|--------------|------|-----|
| Appearance / sidebar | `/settings/appearance` | Light or Dark theme, density, rail-only sidebar |
| Security | `/settings/security` | Session / policy (admin) |
| API access | `/settings/api-access` | Tokens for automation |
| AI providers | `/settings/ai-providers` | Optional LLM for wizards |

Full admin env vars and production checklist: [Admin basics](admin-basics.md) and [Handbook — Admin](../handbook/admin-configuration.md).

## Related

- [Getting Started](getting-started.md)
- [Page-by-page guides](pages/README.md)
