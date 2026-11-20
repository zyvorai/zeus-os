# Costs

## Purpose

Cluster cost dashboard: monthly spend trends, namespace and resource-type breakdowns, top expensive VMs, and optimization opportunities.

## When to use it

- Monthly spend review for the whole cluster
- Find which namespaces or VMs drive cost
- Scan optimization opportunities before deeper FinOps work
- Compare projected spend over the last 30 days

## How to get there

- Route: `/costs`
- Nav: **Cost → Costs**
- Related: `/cost-intelligence`, `/cost-allocation`, `/budget-alerts`

## Operate from the console (UX)

1. Open `/costs` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Cluster cost dashboard: monthly spend trends, namespace and resource-type breakdowns, top expensive VMs, and optimizatio….
3. Select the time range and scope (cluster / namespace / tenant).
4. Drill from rollup → workload; export or create a budget/alert if the page offers it.
5. Cross-check rightsizing recommendations before resizing production VMs.
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Cluster cost dashboard: monthly spend trends, namespace and resource-type breakdowns, top expensive .
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [Cost Intelligence](./cost-intelligence.md)
- [Cost Allocation](./cost-allocation.md)
- [Rightsizing](./rightsizing.md)
- [Budget Alerts](./budget-alerts.md)
