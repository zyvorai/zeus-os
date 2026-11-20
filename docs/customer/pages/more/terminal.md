# Terminal

## Purpose

In-browser cluster shell: pick a pod/container, open an authenticated WebSocket session, and run commands with multi-tab support.

## When to use it

- Exec into a workload without leaving the dashboard
- Keep recent namespace/pod targets handy for repeat access
- Open several shells (multi-session tabs) during an incident
- Deep-link from a pod context with `?namespace=&pod=&container=`

## How to get there

- Route: `/terminal`
- Nav: **Top bar → Terminal** (also Support / quick links)
- Related: `/pods`, `/vms`, `/api-docs`

## Operate from the console (UX)

1. Open `/terminal` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: In-browser cluster shell: pick a pod/container, open an authenticated WebSocket session, and run commands with multi-tab….
3. Pick a session target (VM / pod / node) and attach VNC, serial, SSH, or RDP as offered.
4. Confirm HTTPS for in-browser VNC; RDP/SSH use guest credentials, not Zeus login.
5. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: In-browser cluster shell: pick a pod/container, open an authenticated WebSocket session, and run com.
6. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [Virtual Machines](../core/vms.md)
- [API Docs](./api-docs.md)
- [Debug](./debug.md)
- [Pods](../../PAGE_INDEX.md) — `/pods`

