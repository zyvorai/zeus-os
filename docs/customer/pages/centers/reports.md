# Reports

## Purpose

Executive and operational report catalog — shortcuts into health, protection, DR, security, network, cost, audit, and compliance exports.

## When to use it

- Brief leadership with an executive health path
- Jump to Velero or DR readiness reporting surfaces
- Export compliance evidence or a CSV catalog of report links
- Open security posture or zero-trust network views

## How to get there

- Route: `/reports`
- Nav: **Command palette / deep link**
- Related: `/system-health`, `/velero`, `/compliance`, `/cost-intelligence`

## Operate from the console (UX)

1. Open `/reports` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Executive and operational report catalog — shortcuts into health, protection, DR, security, network, cost, audit, and co….
3. Use the center’s primary CTA (create, scan, open workbench, ask Zeus when reasoning is required).
4. Deterministic navigation and filters call the router directly — do not round-trip those through Ask Zeus.
5. Pin frequent pages to Favorites (`/favorites`).
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Executive and operational report catalog — shortcuts into health, protection, DR, security, network,.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [System Health](../observe/system-health.md)
- [Velero](../run/velero.md)
- [Backup & DR](./backup-dr.md)
- [Cost Intelligence](../cost/cost-intelligence.md)
