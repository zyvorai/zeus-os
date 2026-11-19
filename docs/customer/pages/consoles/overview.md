# Consoles & remote access

## Purpose

Reach the guest: graphical VNC, serial text console, and native RDP/SSH via NodePort expose.

## When to use it

- Install or configure an OS interactively
- Debug boot failures (serial)
- Give operators desktop/SSH access without kubectl port-forward

## How to get there

| Method | Entry |
|--------|--------|
| From a VM | Workbench → Console / Remote access |
| Multi-session | `/consolehub` |
| Pop-out VNC | `/vm-console/vnc/...` (from UI) |
| Workspace | `/workspace` |

## Operate from the console (UX)

1. Open `/overview` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Reach the guest: graphical VNC, serial text console, and native RDP/SSH via NodePort expose.
3. Use filters and search on the page; open a row for detail / inspector.
4. Run the primary action (create, apply, run, export) from the PageHead or empty-state CTA.
5. Confirm success via toast + refreshed inventory; check Incidents if the action fails.
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Reach the guest: graphical VNC, serial text console, and native RDP/SSH via NodePort expose.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [VM workbench](../core/vm-workbench.md)
- [ConsoleHub](consolehub.md)
- [Terminal](../../PAGE_INDEX.md) — `/terminal` for cluster/pod shells
