# Forecasting

## Purpose

AI-assisted resource predictions — per-VM and cluster forecasts, capacity recommendations, and seasonal pattern detection — to plan before you run out of headroom.

## When to use it

- Estimate when a VM or the cluster will hit a resource ceiling
- Review capacity recommendations before buying nodes
- Spot weekly or daily seasonal load patterns
- Feed planning discussions with trend labels (increasing / decreasing / stable)

## How to get there

- Route: `/forecasting`
- Nav: **Observe → Forecasting**
- Related: `/capacity`, `/heatmap`, `/cost-intelligence`

## Operate from the console (UX)

1. Open `/forecasting` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: AI-assisted resource predictions — per-VM and cluster forecasts, capacity recommendations, and seasonal pattern detectio….
3. Filter firing vs resolved; open an incident or alert for guided remediation.
4. Jump to related VMs/pods/nodes from the detail panel.
5. Silence only with an expiry when paging must pause — keep the alert visible in-ledger.
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: AI-assisted resource predictions — per-VM and cluster forecasts, capacity recommendations, and seaso.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [Capacity](./capacity.md)
- [Resource Heatmap](./heatmap.md)
- [Cost Intelligence](../cost/cost-intelligence.md)
- [VM Monitor](./vm-monitor.md)
