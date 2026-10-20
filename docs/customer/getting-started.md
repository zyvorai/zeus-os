# Getting Started with Zeus OS

This guide gets a customer from “I have a URL” to first useful work in the web dashboard.

## What you need

| Requirement | Notes |
|-------------|--------|
| Kubernetes cluster with **KubeVirt** installed | Zeus is day-2 ops — it does not bootstrap the cluster |
| Reachable Zeus OS URL | Often `https://<host>:30050` (NodePort) or `https://<host>:5050` |
| Login credentials | Provided by your platform admin (local / LDAP / SAML / OIDC) |
| Browser | Modern Chromium, Firefox, or Safari. **HTTPS required for in-browser VNC** |

Optional: `kubectl` access is not required for normal UI work.

## 1. Open the dashboard

1. Open the URL your admin shared (example: `https://cluster.example:30050`).
2. If the browser warns about a self-signed certificate, confirm with your admin, then proceed (or install the org CA).
3. You should land on login, or directly on **Home** (`/`) if auth is disabled in a lab.

**Common mistake:** Port **5092** is GuestKit / Machina territory on some Zyvor stacks — not Zeus OS. Prefer the URL that ends in the Zeus NodePort (often **30050**) or the documented ingress host.

## 2. Sign in

Auth depends on how the deployment is configured:

| Mode | What you do |
|------|-------------|
| Local users | Username + password from your admin |
| LDAP / Active Directory | Corporate directory credentials |
| SAML / OIDC | “Sign in with …” → identity provider |
| Lab only | `ZEUS_OS_NO_AUTH` — no login (never use in production) |

API automation uses bearer tokens / API keys from **Settings → API access** or Identity Center — not the guest OS password.

Windows **RDP** prompts for the **guest** credentials, not your Zeus login.

## 3. Orient yourself (60 seconds)

1. **Home** (`/`) — chapter pulse, **Get the highlights**, and teaser into **Attention**, VMs, Health.
2. **Attention** (`/attention`) — ranked actions, Issue Stream, and day-2 activity when Home shows warnings.
2. **Sidebar / Finder** — centers such as VMs, Storage, Monitoring, Settings.
3. **Command palette** — open with the keyboard shortcut shown in the shell (typically ⌘K / Ctrl+K) and type a page name.
4. **Browse vs workbench** — inventory lists are safe to explore; power actions live on the VM workbench so production VMs are harder to disrupt by accident.
5. **Getting started checklist** — first-time visitors see a banner on Home; click **Getting started checklist** (or **Help → Getting Started**) for a short, role-aware task list (admins get cluster/team setup, everyone else gets "find/create a VM", "open a console", "check cost"). Progress is saved to your account, so it follows you across devices and browsers — not just this one tab.

See [Using the Dashboard](using-the-dashboard.md) for navigation details.

## 4. Your first five workflows

### A. Browse and power a VM

1. Go to **VMs** → `/vms`.
2. Filter by namespace or name.
3. Open a VM → `/vms/<namespace>/<name>` (workbench).
4. Use **Start / Stop / Restart / Pause** as needed.
5. Confirm status updates in the inventory.

Guide: [Virtual Machines](pages/core/vms.md)

### B. Open a live console

1. From a **Running** VM workbench, open **Console → VNC** (graphical) or **Serial** (text).
2. VNC needs HTTPS. If the session is black, click **Focus** in the console toolbar.
3. For RDP/SSH: use **Remote access** to expose a NodePort, then connect with your OS client (downloadable `.rdp` or `ssh` command). VNC remains the in-browser default.

Guide: [Consoles & remote access](pages/consoles/overview.md)

### C. Create a VM

1. Open **VM setup** → `/vm-setup` (or `/vms/new`).
2. Choose instance type / preference / template (or AI-assisted manifest if enabled).
3. For **Windows**: if Settings → Network shows Kryton **Connected**, prefer the Kryton catalog
   path (template IDs like `windows-11-enterprise`). Otherwise use Autounattend / ISO.
4. Review disks, network, and namespace.
5. Deploy — the VM appears under `/vms` (Kryton creates deep-link via `providerRef`).

Guides: [Create a machine](pages/core/vm-setup.md) · [Windows via Kryton](pages/cluster/windows-via-kryton.md)

### D. Snapshot and restore

1. **Snapshot Manager** → `/snapshot-manager` — take an on-demand or scheduled snapshot.
2. To recover: **Restore Wizard** → `/restore-wizard` and follow the guided restore.

Guide: [Snapshots](pages/run/snapshots.md)

### E. Cost check and rightsizing

1. **Cost Intelligence** → `/cost-intelligence` — spend by VM / namespace.
2. **Rightsizing** → `/rightsizing` — idle / oversized recommendations.

Guide: [Cost Intelligence](pages/cost/cost-intelligence.md)

## 5. Optional: TUI and CLI

Same cluster, different surfaces:

```bash
# Terminal UI (k9s-style)
zeus-os
zeus-os production    # namespace filter

# Headless CLI (examples depend on install path)
zeus-os-cli --help
```

API: `/api/v1` on the same host as the dashboard. OpenAPI lives under **Developer Center** / **API Docs** (`/api-docs`).

## Next steps

| Role | Read next |
|------|-----------|
| VM operator | [Page guides — Core](pages/README.md#core) |
| Platform admin | [Admin basics](admin-basics.md) |
| Security / network | [PacketWolf](pages/more/packetwolf.md) |
| Full capability map | [Feature Guide](../zeus-os-customer-feature-guide.md) |

---

*If something fails at login or console, see [Troubleshooting](../handbook/troubleshooting.md).*
