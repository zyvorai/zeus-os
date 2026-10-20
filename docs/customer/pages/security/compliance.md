# Compliance

## Purpose

Scores your VMs against Zeus OS policy checks and gives you a cluster grade, per-category pass rates, and a per-VM breakdown you can export as evidence.

## When to use it

- Produce a point-in-time compliance snapshot before an audit
- Find which VMs are dragging the cluster score down and why
- Track a category (for example hardening or backup coverage) over time
- Hand an auditor a machine-readable report

## How to get there

- Route: `/compliance`
- Nav: **Security -> Compliance**
- Related: `/compliance?tab=frameworks`, `/auth-audit`, `/backup-dr`, `/reports`

## Operate from the console (UX)

1. Open `/compliance` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Scores your VMs against Zeus OS policy checks and gives you a cluster grade, per-category pass rates, and a per-VM break….
3. Filter findings / policies by severity or namespace.
4. Open a row for evidence and remediation; use change-approval gates when enabled.
5. Export or acknowledge as your role allows — do not mute crit without a live condition handled.
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Scores your VMs against Zeus OS policy checks and gives you a cluster grade, per-category pass rates.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [Security](./security.md)
- [Events (Audit log tab)](../observe/events.md)
- [Image Scanning](./image-scanning.md)
- [Snapshots](../run/snapshots.md)
- [Compliance Frameworks](../../PAGE_INDEX.md) — `/compliance?tab=frameworks`
