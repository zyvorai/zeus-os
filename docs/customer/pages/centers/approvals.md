# Approvals

## Purpose

Single inbox for decisions waiting on you — day-2 remediations pending approval and change requests.

## When to use it

- Clear pending remediations without opening Auto-Remediation first
- Approve or reject VM change requests
- Confirm inbox zero before a change freeze ends
- Pair with War Room during live incidents

## How to get there

- Route: `/approvals`
- Nav: **Workspace → Approvals**
- Related: `/auto-remediation`, `/war-room`, `/change-approval`

## Operate from the console (UX)

1. Open `/approvals` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Single inbox for decisions waiting on you — day-2 remediations pending approval and change requests.
3. Use the center’s primary CTA (create, scan, open workbench, ask Zeus when reasoning is required).
4. Deterministic navigation and filters call the router directly — do not round-trip those through Ask Zeus.
5. Pin frequent pages to Favorites (`/favorites`).
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Single inbox for decisions waiting on you — day-2 remediations pending approval and change requests.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [Auto-Remediation](../more/auto-remediation.md)
- [War Room](./war-room.md)
- [Change Approval](../../PAGE_INDEX.md) — `/change-approval`
