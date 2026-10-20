# Console Sessions

## Purpose

Legacy route that redirects to ConsoleHub’s active sessions tab. Bookmarks and Settings links still resolve.

## When to use it

- Open an old `/console-sessions` bookmark
- Reach session inventory after following a Settings deep link
- Prefer ConsoleHub directly for day-to-day console work
- Audit who holds live console tunnels

## How to get there

- Route: `/console-sessions` → redirects to `/consolehub?tab=sessions`
- Nav: **Command palette / deep link** (not a separate sidebar page)
- Related: `/consolehub`, VM workbench consoles

## Operate from the console (UX)

1. Open `/console-sessions` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Legacy route that redirects to ConsoleHub’s active sessions tab. Bookmarks and Settings links still resolve.
3. Pick a session target (VM / pod / node) and attach VNC, serial, SSH, or RDP as offered.
4. Confirm HTTPS for in-browser VNC; RDP/SSH use guest credentials, not Zeus login.
5. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Legacy route that redirects to ConsoleHub’s active sessions tab. Bookmarks and Settings links still .
6. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [ConsoleHub](../consoles/consolehub.md)
- [Consoles overview](../consoles/overview.md)
- [VM workbench](../core/vm-workbench.md)
