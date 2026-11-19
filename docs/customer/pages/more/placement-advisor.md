# Placement Advisor

## Purpose

Legacy nav entry for smart VM placement. The dashboard redirects this route to **Placement**, where node scoring and topology-manager recommendations live.

## When to use it

- Choosing a host for a new or resized VM
- Balancing load across zones or affinity constraints
- Reviewing topology-manager placement suggestions
- Coordinating with NUMA / topology policies before pin work

## How to get there

- Route: `/placement-advisor` (redirects to `/placement`)
- Nav: **More → Insights → Placement Advisor**
- Related: `/placement`, `/topology-manager`, `/nodes`

## Operate from the console (UX)

1. Open `/placement-advisor` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Legacy nav entry for smart VM placement. The dashboard redirects this route to **Placement**, where node scoring and top….
3. Use the center’s primary CTA (create, scan, open workbench, ask Zeus when reasoning is required).
4. Deterministic navigation and filters call the router directly — do not round-trip those through Ask Zeus.
5. Pin frequent pages to Favorites (`/favorites`).
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Legacy nav entry for smart VM placement. The dashboard redirects this route to **Placement**, where .
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [Placement](./placement.md)
- [Topology Mgr](./topology-manager.md)
- [Nodes](../cluster/nodes.md)
- [Migrations](../run/migrations.md)
