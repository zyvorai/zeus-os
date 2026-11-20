# Resource Canvas

## Purpose

Spatial map of compute, storage, networking, and AI entry points — click a node to open its window.

## When to use it

- Orient visually across VMs and infra hubs
- Jump from a canvas VM node into console deep link
- Open Storage, Network Flow, or AI providers from fixed infra nodes
- Give operators a single spatial overview of recent VMs

## How to get there

- Route: `/workspace`
- Nav: **Modules → Resource Canvas**
- Related: `/vms`, `/storage`, `/network-flow`, `/settings/ai-providers`

## Operate from the console (UX)

1. Open `/workspace` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Spatial map of compute, storage, networking, and AI entry points — click a node to open its window.
3. Pick a session target (VM / pod / node) and attach VNC, serial, SSH, or RDP as offered.
4. Confirm HTTPS for in-browser VNC; RDP/SSH use guest credentials, not Zeus login.
5. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Spatial map of compute, storage, networking, and AI entry points — click a node to open its window.
6. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [Virtual Machines](../core/vms.md)
- [Topology](../more/topology.md)
- [Consoles overview](../consoles/overview.md)
