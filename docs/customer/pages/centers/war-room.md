# War Room

## Purpose

Live incident assembly — active incident, affected VMs and nodes, recommended actions, pending remediations, and a warning-event feed in one place.

## When to use it

- Respond to a P1 without hopping across dozens of routes
- Approve or reject day-2 remediations inline
- Evacuate or act on affected nodes with confirm-then-run controls
- Confirm the cluster is healthy when no incident is active

## How to get there

- Route: `/war-room`
- Nav: **Workspace → War Room**
- Related: `/incidents`, `/approvals`, `/auto-remediation`, `/time-machine`

## Operate from the console (UX)

1. Open `/war-room` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Live incident assembly — active incident, affected VMs and nodes, recommended actions, pending remediations, and a warni….
3. Use the center’s primary CTA (create, scan, open workbench, ask Zeus when reasoning is required).
4. Deterministic navigation and filters call the router directly — do not round-trip those through Ask Zeus.
5. Pin frequent pages to Favorites (`/favorites`).
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Live incident assembly — active incident, affected VMs and nodes, recommended actions, pending remed.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [Incidents](../observe/incidents.md)
- [Approvals](./approvals.md)
- [Auto-Remediation](../more/auto-remediation.md)
- [Time Machine](./time-machine.md)
