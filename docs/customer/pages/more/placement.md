# Placement

## Purpose

Heuristic node scores from live topology, plus topology-manager API recommendations, so you can pick a suitable host for VM CPU/memory and affinity needs.

## When to use it

- Place a new VM on the least-loaded capable node
- Prefer a zone or label affinity before scheduling
- Compare topology-manager recs with client-side scores
- Review host groups used by your placement policy

## How to get there

- Route: `/placement`
- Nav: **More → Insights → Placement**
- Related: `/placement-advisor` (alias), `/topology-manager`, `/nodes`

## Operate from the console (UX)

1. Open `/placement` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Heuristic node scores from live topology, plus topology-manager API recommendations, so you can pick a suitable host for….
3. Use the center’s primary CTA (create, scan, open workbench, ask Zeus when reasoning is required).
4. Deterministic navigation and filters call the router directly — do not round-trip those through Ask Zeus.
5. Pin frequent pages to Favorites (`/favorites`).
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Heuristic node scores from live topology, plus topology-manager API recommendations, so you can pick.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [Placement Advisor](./placement-advisor.md)
- [Topology Mgr](./topology-manager.md)
- [Nodes](../cluster/nodes.md)
- [VMs](../core/vms.md)
