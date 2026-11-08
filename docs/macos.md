# Mac app

A native macOS client for a running Zeus OS server, built with SwiftUI. It uses the same REST API as the web dashboard, so it shows what the dashboard shows.

- Requires macOS 27.
- Signed with a Developer ID and notarized by Apple; open the DMG and drag Zeus to Applications.
- Source and build instructions: [`macos/`](https://github.com/zyvorai/zeus-os/tree/main/macos) and the *Mac app* section of the README.

## Signing in

Add a server (its URL, your username and password). The session token can be kept in the Keychain so the next launch signs you in straight away. You can save several servers and switch between them from the sidebar footer.

If the server presents a certificate the Mac doesn't already trust, the app shows its fingerprint and asks whether to trust it. A trusted fingerprint is pinned to that server; if it later changes, you are asked again.

## Roles

The app follows your server role. **Viewers** get a read-only app. **Editors and admins** see the write actions, and every destructive action asks for confirmation first. If the server refuses an action, its message is shown.

## What's in the sidebar

| Group | Screens |
|---|---|
| Run | Overview, Machines, Migrations, Templates, VM Groups |
| Protect | Snapshots, Backups |
| Storage | Storage, DR Plans, Velero, Disks & Images |
| Cost | Cost, Optimization, FinOps |
| Secure | Audit, Compliance, Policies & Scans, Access, Image Scanning, Policies, Network Policies |
| Respond | Alert Rules, Channels, Notifications, SLOs, SLO Budgets, Incidents, Tenancy |
| Observe | Alerts, Metrics & Dashboards, Activity & Health, Logs, Events, Topology, APM, Traces, Chaos, Capacity, AI Center and more |
| Network | Network, Services & Ingress, Cilium, VM Shield, Containments, DNS & IPAM, Mesh & Services |
| Kubernetes | Workloads, Config, VM Objects, Cluster Resources |
| Scheduling | Placement, Classes & Budgets, Quotas & Governance, Autoscaling, Devices & Hosts |
| Deliver | Helm, GitOps, Delivery |
| Automate | Tasks, Workflows, Workflow Runs, Rollouts |
| Identity | Users & Sessions, API Tokens, RBAC |
| Consoles | Pod Terminal, Console Access |
| Platform | Platform Admin, Licensing & Onboarding, Integrations, Fleet, Nodes & Hosts, Operators, Catalog, Add-ons, Lifecycle |

Groups collapse, the Filter box narrows the list, and ⌘1 to ⌘9 jump to the first nine screens in sidebar order.

## Machines

- A sortable, searchable table with an inspector showing CPU, memory, network and disk history (15 minute, 1 hour and 6 hour ranges).
- Start, stop, restart, pause, clone, live-migrate and delete, plus hot-plug CPU, memory and disks and cloud-init editing, for editors and admins.
- A text serial console from the inspector, and a native graphical console (RFB/VNC, raw and CopyRect encodings, mouse and keyboard, Ctrl+Alt+Del). Graphical console sessions are shared, never exclusive.

## Alerts and notifications

The sidebar badge counts alerts that still need attention, which excludes acknowledged ones. Editors and admins can acknowledge and resolve alerts, create and edit rules, create email (SMTP) channels, enable, disable, test and delete channels, and create SLOs. Channel passwords are typed into a secure field, sent once and never shown again. "Send Test" sends a real message, so it asks first.

The app can post macOS notifications for new alerts, shows machines and alert counts in the menu bar, indexes machines in Spotlight, and offers Shortcuts actions for power operations.

## Helm and containments

- **Helm**: browse releases and revision history; editors and admins can roll back, uninstall, and install or upgrade by sending a JSON body. The server documents the install and upgrade bodies only as free-form JSON, so the app validates that you entered a JSON object and sends it as written.
- **Containments**: create a containment on a workload, change its auto-release time, release it or roll it back. The server can't list containments, so the screen remembers the IDs this Mac created or looked up and re-reads them on open.

## Live updates

The app polls every 5 seconds while in front, more slowly behind, and backs off when the server is unreachable. A status indicator in the toolbar shows when it is reconnecting.

## Current limits

- **Not yet tried against a live server**: write actions, both consoles, notifications, Shortcuts actions and the trust prompt. They are unit-tested and compile.
- **The server has no API for**: cluster cordon and drain (only uncordon), other notification channel types, Argo CD and Flux sync, enabling or disabling scheduled operations, SLO deletion.
- Many read-only screens follow the server's OpenAPI document, because the reference server had no data for them.

## Building a release

```sh
macos/scripts/release.sh                       # build, sign with hardened runtime, make a signed DMG
NOTARY_PROFILE=zeus macos/scripts/release.sh   # also notarize, staple and check with Gatekeeper
```

One-time setup stores your notarization credentials in the keychain:

```sh
xcrun notarytool store-credentials zeus --key AuthKey_XXXX.p8 --key-id KEYID --issuer ISSUER-UUID
```

The script needs a *Developer ID Application* certificate in the keychain, writes to `macos/dist/` (git-ignored) and stops unless Apple reports the submission as Accepted.
