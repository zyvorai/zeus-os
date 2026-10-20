# Nodes

## Purpose

Kubernetes worker/control-plane node inventory: capacity, conditions, and drain/placement context for VMs.

## When to use it

- Before live migration or maintenance
- Find which node hosts a hot VM
- Investigate NotReady / pressure conditions

## How to get there

- Route: `/nodes`
- Nav: **Cluster → Nodes**

## Operate from the console (UX)

1. Open `/nodes` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Kubernetes worker/control-plane node inventory: capacity, conditions, and drain/placement context for VMs.
3. Use namespace / label filters; open an object for inspector details.
4. Mutations (drain, resize PVC, attach NAD) go through confirm sheets — wait for status refresh.
5. If empty: broaden namespace filter, confirm RBAC, and that the cluster API is reachable.
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Kubernetes worker/control-plane node inventory: capacity, conditions, and drain/placement context fo.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [Live Migrations](../run/migrations.md)
- [Capacity](../../PAGE_INDEX.md) — `/capacity`
- [Placement](../../PAGE_INDEX.md) — `/placement`
