# Debug

## Purpose

Host-level diagnostics for the Zeus OS node: live system stats, network interfaces, disk partitions, services, and a downloadable support bundle.

## When to use it

- Investigate CPU, memory, or disk pressure on the control host
- Confirm interface and partition layout during an outage
- Capture a support bundle for vendor or platform escalation
- Watch host metrics with auto-refresh while reproducing an issue

## How to get there

- Route: `/debug`
- Nav: **More → Tools & settings → Debug**
- Related: `/kernel`, `/system-health`, `/host`

## Operate from the console (UX)

1. Open `/debug` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Host-level diagnostics for the Zeus OS node: live system stats, network interfaces, disk partitions, services, and a dow….
3. Use the center’s primary CTA (create, scan, open workbench, ask Zeus when reasoning is required).
4. Deterministic navigation and filters call the router directly — do not round-trip those through Ask Zeus.
5. Pin frequent pages to Favorites (`/favorites`).
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Host-level diagnostics for the Zeus OS node: live system stats, network interfaces, disk partitions,.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [Kernel Info](./kernel.md)
- [System Health](../observe/system-health.md)
- [API Playground](./api-playground.md)
- [Host Info](../../PAGE_INDEX.md) — `/host`

