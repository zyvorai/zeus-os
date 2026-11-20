# Time Machine

## Purpose

Cluster DVR and per-VM flight recorder — scrub recorded state over time. Frames come from the server-side sampler ring buffer.

## When to use it

- Replay cluster health (nodes, VMs, pressure) around an incident
- Rewind a single VM’s lifecycle phases and node placement
- Confirm the recorder is collecting after a fresh deploy
- Correlate War Room timelines with historical frames

## How to get there

- Route: `/time-machine` (alias `/dvr` redirects here)
- Nav: **Workspace → Time Machine**
- Related: `/war-room`, `/incidents`, `/system-health`

## Operate from the console (UX)

1. Open `/time-machine` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Cluster DVR and per-VM flight recorder — scrub recorded state over time. Frames come from the server-side sampler ring b….
3. Use the center’s primary CTA (create, scan, open workbench, ask Zeus when reasoning is required).
4. Deterministic navigation and filters call the router directly — do not round-trip those through Ask Zeus.
5. Pin frequent pages to Favorites (`/favorites`).
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Cluster DVR and per-VM flight recorder — scrub recorded state over time. Frames come from the server.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [War Room](./war-room.md)
- [Incidents](../observe/incidents.md)
- [System Health](../observe/system-health.md)
