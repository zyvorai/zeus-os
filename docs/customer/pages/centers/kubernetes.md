# Kubernetes Center

## Purpose

Hub for the container layer under your Zeus virtual datacenter — cluster pulse plus shortcuts to pods, services, nodes, and related day-2 tools.

## When to use it

- Check pod and node readiness at a glance
- Jump to Pods, Services, or Nodes inventory
- Open GitOps, catalog, MetalLB, or Task Center from one place
- Operate Kubernetes Pro features gated by edition

## How to get there

- Route: `/kubernetes`
- Nav: **Compute → Kubernetes** (workspace switcher also lists Kubernetes)
- Related: `/pods`, `/services`, `/nodes`, `/tasks`

## Operate from the console (UX)

1. Open `/kubernetes` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Hub for the container layer under your Zeus virtual datacenter — cluster pulse plus shortcuts to pods, services, nodes, ….
3. Use the center’s primary CTA (create, scan, open workbench, ask Zeus when reasoning is required).
4. Deterministic navigation and filters call the router directly — do not round-trip those through Ask Zeus.
5. Pin frequent pages to Favorites (`/favorites`).
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Hub for the container layer under your Zeus virtual datacenter — cluster pulse plus shortcuts to pod.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [Pods](../cluster/pods.md)
- [Task Center](./tasks.md)
- [Operators](../more/operators.md)
