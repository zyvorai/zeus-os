# Support

## Purpose

Operator support hub — download a redacted diagnostics bundle and jump to health, debug, API docs, audit, and terminal tools.

## When to use it

- Collect a support bundle for Zyvor or internal escalation
- Open System Health or Debug Tools during an outage
- Share API docs with integrators
- Keep a single entry point for operator diagnostics

## How to get there

- Route: `/support`
- Nav: **Command palette / deep link**
- Related: `/system-health`, `/debug`, `/api-docs`, `/events?tab=audit`, `/terminal`

## Operate from the console (UX)

1. Open `/support` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Operator support hub — download a redacted diagnostics bundle and jump to health, debug, API docs, audit, and terminal t….
3. Use the center’s primary CTA (create, scan, open workbench, ask Zeus when reasoning is required).
4. Deterministic navigation and filters call the router directly — do not round-trip those through Ask Zeus.
5. Pin frequent pages to Favorites (`/favorites`).
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Operator support hub — download a redacted diagnostics bundle and jump to health, debug, API docs, a.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [System Health](../observe/system-health.md)
- [Debug Tools](../more/debug.md)
- [Developer Center](./developer-center.md)
