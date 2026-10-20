# ConsoleHub

## Purpose

Unified launcher and session manager for browser consoles — multiple VMs, policies, and session visibility.

## When to use it

- Operate several consoles side by side
- Audit who has active console sessions
- Apply console access policy at a fleet level

## How to get there

- Route: `/consolehub`
- Related: `/console-sessions`, `/workspace`

## Operate from the console (UX)

1. Open `/consolehub` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Unified launcher and session manager for browser consoles — multiple VMs, policies, and session visibility.
3. Pick a session target (VM / pod / node) and attach VNC, serial, SSH, or RDP as offered.
4. Confirm HTTPS for in-browser VNC; RDP/SSH use guest credentials, not Zeus login.
5. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Unified launcher and session manager for browser consoles — multiple VMs, policies, and session visi.
6. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [Consoles overview](overview.md)
- [Virtual Machines](../core/vms.md)
