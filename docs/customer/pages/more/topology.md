# Topology

## Purpose

Live map of infrastructure relationships — nodes, VMs, networks, and dependencies visualized.

## When to use it

- Understand blast radius before a change
- Explain environment layout to a new operator
- Correlate incidents with dependency edges

## How to get there

- Route: `/topology`
- Nav: **More → Mesh & traffic → Topology**
- Related: `/dependencies`, `/network-flow`

## Operate from the console (UX)

1. Open `/topology` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Live map of infrastructure relationships — nodes, VMs, networks, and dependencies visualized.
3. Use the center’s primary CTA (create, scan, open workbench, ask Zeus when reasoning is required).
4. Deterministic navigation and filters call the router directly — do not round-trip those through Ask Zeus.
5. Pin frequent pages to Favorites (`/favorites`).
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Live map of infrastructure relationships — nodes, VMs, networks, and dependencies visualized.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [Dependencies](../../PAGE_INDEX.md) — `/dependencies`
- [Network Flow](../../PAGE_INDEX.md) — `/network-flow`
- [PacketWolf](../more/packetwolf.md)
