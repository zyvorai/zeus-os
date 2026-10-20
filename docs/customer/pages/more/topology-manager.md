# Topology Mgr

## Purpose

Node topology detail for NUMA zones, CPU pins, device allocations, and topology policies — deeper than the live map on Topology.

## When to use it

- Plan CPU pinning or device-aware VM placement
- Inspect NUMA memory and device locality per node
- Audit topology policies and which nodes they cover
- Correlate with Placement scores before scheduling

## How to get there

- Route: `/topology-manager`
- Nav: **More → Mesh & traffic → Topology Mgr**
- Related: `/topology`, `/placement`, `/nodes`

## Operate from the console (UX)

1. Open `/topology-manager` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Node topology detail for NUMA zones, CPU pins, device allocations, and topology policies — deeper than the live map on T….
3. Use the center’s primary CTA (create, scan, open workbench, ask Zeus when reasoning is required).
4. Deterministic navigation and filters call the router directly — do not round-trip those through Ask Zeus.
5. Pin frequent pages to Favorites (`/favorites`).
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Node topology detail for NUMA zones, CPU pins, device allocations, and topology policies — deeper th.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [Topology](./topology.md)
- [Placement](./placement.md)
- [Nodes](../cluster/nodes.md)
- [Dependencies](./dependencies.md)
