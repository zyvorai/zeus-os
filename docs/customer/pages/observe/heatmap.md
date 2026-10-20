# Resource Heatmap

## Purpose

Cluster-wide utilization heatmap built from per-VM cells rolled up by node — CPU, memory, disk, and network pressure for capacity planning.

## When to use it

- Spot hot nodes (high CPU or memory) before migrations fail
- Find underutilized nodes for placement or consolidation
- Watch live pressure during a load test or incident
- Cross-check Capacity numbers with a spatial view

## How to get there

- Route: `/heatmap`
- Nav: **Observe → Resource Heatmap**
- Related: `/capacity`, `/vm-monitor`, `/nodes`

## Operate from the console (UX)

1. Open `/heatmap` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Cluster-wide utilization heatmap built from per-VM cells rolled up by node — CPU, memory, disk, and network pressure for….
3. Filter firing vs resolved; open an incident or alert for guided remediation.
4. Jump to related VMs/pods/nodes from the detail panel.
5. Silence only with an expiry when paging must pause — keep the alert visible in-ledger.
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Cluster-wide utilization heatmap built from per-VM cells rolled up by node — CPU, memory, disk, and .
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [Capacity](./capacity.md)
- [VM Monitor](./vm-monitor.md)
- [Forecasting](./forecasting.md)
- [Nodes](../cluster/nodes.md)
