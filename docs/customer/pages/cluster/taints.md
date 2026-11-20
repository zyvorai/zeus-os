# Taints

## Purpose

Read-only analysis of node taints and which VMs tolerate them — plus scheduling impact warnings for unschedulable guests.

## When to use it

- Before maintenance: see NoSchedule / PreferNoSchedule / NoExecute coverage
- Find VMs that tolerate a given tainted node
- Spot unschedulable VM counts from the analysis endpoint
- Search nodes or taint keys when placement fails

## How to get there

- Route: `/taints`
- Nav: **Cluster → Taints**
- Related: `/nodes`, `/vms`, `/priority-classes`

## Operate from the console (UX)

1. Open `/taints` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Read-only analysis of node taints and which VMs tolerate them — plus scheduling impact warnings for unschedulable guests.
3. Use namespace / label filters; open an object for inspector details.
4. Mutations (drain, resize PVC, attach NAD) go through confirm sheets — wait for status refresh.
5. If empty: broaden namespace filter, confirm RBAC, and that the cluster API is reachable.
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Read-only analysis of node taints and which VMs tolerate them — plus scheduling impact warnings for .
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [Nodes](./nodes.md)
- [VMs](../core/vms.md)
- [Priority Classes](./priority-classes.md)
