# Incident chat

## Purpose

Lightweight multi-user chat channel for incident collaboration. Marked **labs** in navigation; messages sync through Zeus OS, while slash commands run locally.

## When to use it

- Coordinate responders during an active incident thread
- Leave a short status trail without leaving the dashboard
- Use offline-cached messages when the labs API is unreachable
- Practice war-room style notes before escalating to Incidents or War Room

## How to get there

- Route: `/incident-chat`
- Nav: **Observe → Incident chat** (labs tier)
- Related: `/incidents`, `/war-room`

## Operate from the console (UX)

1. Open `/incident-chat` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Lightweight multi-user chat channel for incident collaboration. Marked **labs** in navigation; messages sync through Zeu….
3. Filter firing vs resolved; open an incident or alert for guided remediation.
4. Jump to related VMs/pods/nodes from the detail panel.
5. Silence only with an expiry when paging must pause — keep the alert visible in-ledger.
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Lightweight multi-user chat channel for incident collaboration. Marked **labs** in navigation; messa.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [Incidents](./incidents.md)
- [System Health](./system-health.md)
- [Alerts](./alerting.md)
- [War Room](../../PAGE_INDEX.md) — `/war-room`
