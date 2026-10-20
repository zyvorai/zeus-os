# Multi-Cluster

## Purpose

Multi-Cluster Command Center — list federation contexts, view the current cluster overview, and compare up to two clusters side by side.

## When to use it

- Confirm which context Zeus OS is talking to
- Compare VM/node counts and health across contexts
- Inventory remote cluster endpoints registered with the API
- Plan DR or migration work across sites

## How to get there

- Route: `/multi-cluster`
- Nav: **More → Resilience → Multi-Cluster**
- Related: `/disaster-recovery`, `/network-flow` (federation tabs)

## Operate from the console (UX)

1. Open `/multi-cluster` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Multi-Cluster Command Center — list federation contexts, view the current cluster overview, and compare up to two cluste….
3. Use the center’s primary CTA (create, scan, open workbench, ask Zeus when reasoning is required).
4. Deterministic navigation and filters call the router directly — do not round-trip those through Ask Zeus.
5. Pin frequent pages to Favorites (`/favorites`).
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Multi-Cluster Command Center — list federation contexts, view the current cluster overview, and comp.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [Disaster Recovery](./disaster-recovery.md)
- [Network Flow](./network-flow.md)
- [Velero](../run/velero.md)
- [Nodes](../cluster/nodes.md)
