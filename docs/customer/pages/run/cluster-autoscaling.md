# Cluster Autoscale

## Purpose

Read-only status of the cluster autoscaler and its node pools: whether it is enabled, how each pool is sized against its min and max, and what scale-up or scale-down actions it is recommending.

## When to use it

- Confirm the cluster autoscaler is enabled and which provider is driving it
- See whether a node pool is pinned at its maximum and blocking scheduling
- Review recommended pool size changes and the savings attached to them
- Check how many scale-ups and scale-downs happened in the last 24 hours

## How to get there

- Route: `/cluster-autoscaling`
- Nav: **Run -> Cluster Autoscale**
- Related: `/autoscaler`, `/nodes`, `/optimization`

## Operate from the console (UX)

1. Open `/cluster-autoscaling` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Read-only status of the cluster autoscaler and its node pools: whether it is enabled, how each pool is sized against its….
3. Prefer dry-run / plan when the UI offers it before mutating production.
4. Start the wizard or job; watch progress and history panels.
5. Confirm completion on the target inventory (VMs, snapshots, backup store).
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Read-only status of the cluster autoscaler and its node pools: whether it is enabled, how each pool .
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [AutoScaler](./autoscaler.md)
- [Nodes](../cluster/nodes.md)
- [Node Drain](./node-drain.md)
- [Operations](./operations.md)
