# Status Page

## Purpose

Operator-facing fleet status board: overall operational / degraded / outage banner, per-VM health, and recent Warning events.

## When to use it

- Share a single “are we up?” view during an incident
- Scan VM health scores and running ratio
- Review recent Warning events as lightweight incident history
- Refresh while waiting for recoveries

## How to get there

- Route: `/status-page`
- Nav: **More → Tools & settings → Status Page**
- Related: `/system-health`, `/incidents`, `/vms`

## Operate from the console (UX)

1. Open `/status-page` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Operator-facing fleet status board: overall operational / degraded / outage banner, per-VM health, and recent Warning ev….
3. Use the center’s primary CTA (create, scan, open workbench, ask Zeus when reasoning is required).
4. Deterministic navigation and filters call the router directly — do not round-trip those through Ask Zeus.
5. Pin frequent pages to Favorites (`/favorites`).
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Operator-facing fleet status board: overall operational / degraded / outage banner, per-VM health, a.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [System Health](../observe/system-health.md)
- [Incidents](../../PAGE_INDEX.md) — `/incidents`
- [Virtual Machines](../core/vms.md)
- [SLA Dashboard](../cost/sla.md)
