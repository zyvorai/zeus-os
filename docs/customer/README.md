# Zeus OS — Customer Documentation

**Zeus OS** is the visual day-2 control plane for **KubeVirt** virtual machines and Kubernetes infrastructure. This package is written for operators, platform admins, and FinOps users — not application developers hacking on the source tree.

| You want to… | Open |
|--------------|------|
| Install and log in | [Getting Started](getting-started.md) |
| Learn the shell (nav, search, workspaces) | [Using the Dashboard](using-the-dashboard.md) |
| Follow a page, step by step | [Page-by-page guides](pages/README.md) |
| Multi-page jobs (create, migrate, contain…) | [Common workflows](workflows.md) |
| Look up any screen by route | [Complete page index](PAGE_INDEX.md) |
| Deploy, auth, TLS, ports | [Admin basics](admin-basics.md) |
| Browse capabilities by theme | [Feature Guide](../zeus-os-customer-feature-guide.md) |
| Fix a symptom | [Troubleshooting](../handbook/troubleshooting.md) · [FAQ](../handbook/faq.md) |

## Printable PDFs

Build branded PDFs from this Markdown (requires Chrome/Chromium + `ui` deps):

```bash
node scripts/customer-docs/build-customer-pdfs.mjs
```

Output lands in [`pdf/`](pdf/):

| PDF | Contents |
|-----|----------|
| `Zeus-OS-Customer-README.pdf` | This overview |
| `Zeus-OS-Getting-Started.pdf` | Access, login, dashboard basics, common workflows |
| `Zeus-OS-Page-by-Page.pdf` | Complete manual — every dashboard page (~190 pages) |
| `Zeus-OS-Admin-Basics.pdf` | Deploy, auth, TLS, ports |

The build regenerates both indexes first and validates that every guide exists.
Check links independently with `node scripts/customer-docs/check-links.mjs`.

Also available: the feature-domain **[Customer Feature Guide PDF](../zeus-os-customer-feature-guide.pdf)** (`node scripts/build-feature-guide.mjs`).

## Product at a glance

```text
  Web dashboard  →  see inventory, operate VMs, consoles, cost, security
  TUI (zeus-os)  →  k9s-style terminal for the same cluster
  CLI            →  script power / snapshot / guest actions
  REST + WS API  →  /api/v1 (OpenAPI in Developer Center)
```

Zeus OS operates what is already running on Kubernetes + KubeVirt. VMware import / conversion lives in sibling products (**Transiva**, **h2kvm**); Zeus links out to those engines from Migrations / Migration Factory.

## How this manual is organized

1. **Getting started** — URL, login, first five workflows.
2. **Using the dashboard** — sidebar, command palette, browse vs workbench.
3. **Page-by-page** — a guide for **every** dashboard screen (purpose, when to use it, steps, related pages). All 132 sidebar routes plus workbench pages, wizards, product centers, and Settings categories are covered.
4. **Page index** — every route with a one-line purpose and a link to its guide.
5. **Admin basics** — what platform admins configure before operators use the UI.

Deep engineering docs live under [`../dev/`](../dev/) and are out of scope for customers.

## Support surfaces (quick map)

| Need | Typical path |
|------|----------------|
| VM inventory & power | `/vms` → workbench `/vms/:namespace/:name` |
| Create a VM | `/vm-setup` or `/vms/new` |
| Live console (VNC/serial) | VM workbench → Console · `/consolehub` |
| Storage / PVCs | `/storage` |
| Network containment | `/packetwolf` |
| Backup / restore | `/velero`, `/backup-wizard`, `/restore-wizard` |
| Cost | `/cost-intelligence`, `/rightsizing` |
| Incidents | `/incidents` |
| Attention | `/attention` |
| Settings | `/settings` |

---

*ZyvorAI Labs · [zyvor.dev](https://zyvor.dev) · Zeus OS (repo `zeus-os`)*
