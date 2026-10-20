# Capacity

## Purpose

Cluster capacity and overcommit dashboard — utilization pulse, per-node breakdown, capacity alerts, planning scenarios, and HA/DRS context.

## When to use it

- Morning check of CPU/memory headroom and overcommit ratios
- Find which nodes are hot or cordoned before placing VMs
- Open linked capacity scenarios for what-if planning
- Act on capacity alerts before they become incidents

## How to get there

- Route: `/capacity`
- Nav: **Observe → Capacity**
- Related: `/forecasting`, `/heatmap`, `/nodes`

## Operate from the console (UX)

1. Open `/capacity` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Cluster capacity and overcommit dashboard — utilization pulse, per-node breakdown, capacity alerts, planning scenarios, ….
3. Filter firing vs resolved; open an incident or alert for guided remediation.
4. Jump to related VMs/pods/nodes from the detail panel.
5. Silence only with an expiry when paging must pause — keep the alert visible in-ledger.
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Cluster capacity and overcommit dashboard — utilization pulse, per-node breakdown, capacity alerts, .
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [Forecasting](./forecasting.md)
- [Resource Heatmap](./heatmap.md)
- [Nodes](../cluster/nodes.md)
- [Cost Intelligence](../cost/cost-intelligence.md)
