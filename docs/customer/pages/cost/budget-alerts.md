# Budget Alerts

## Purpose

Monthly spend budgets for the cluster, a tenant or a namespace. Budgets are stored and evaluated on the server from recorded cost history, and alerts go out through your notification channels once per threshold per month. Spend is an estimate from your configured unit prices, not an invoice.

## When to use it

- Set monthly ceilings for tenant or app namespaces
- Get notified as spend crosses 50 / 80 / 100 percent (or your own thresholds)
- See which budgets are on track, at a warning, over budget, or not measurable yet

## How to get there

- Route: `/budget-alerts`
- Nav: **Cost → Budget Alerts**
- Related: `/cost-allocation`, `/costs`, `/cost-intelligence`, `/notifications`

## Operate from the console (UX)

1. Open `/budget-alerts`.
2. **Add budget**: name, scope (namespace, tenant, or whole cluster for platform admins), monthly limit, thresholds and the notification channels to alert. Tenant users can only budget their own tenant and namespaces.
3. Each row shows month-to-date estimated spend, usage against the limit, a status chip, and which thresholds have already alerted this month. **Unknown** means no cost data has been recorded for that scope this month; it is never shown as zero and never alerts.
4. Budgets saved in this browser by an older version can be imported with **Import N budgets saved in this browser**.
5. **Empty / fail:** No budgets yet shows the empty state; a server error shows a retry panel. A banner appears when cost history recording or the alert engine is switched off.
6. Spend needs recorded history: the sampler records hourly, so a new install shows Unknown until the first sample. If history starts mid-month, month-to-date is a lower bound and the row says so.

Price assumptions are shown at the top of the page; platform admins can edit them there.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs.

## Related pages

- [Cost Allocation](./cost-allocation.md)
- [Costs](./costs.md)
- [Cost Intelligence](./cost-intelligence.md)
- [Alerting (Channels tab)](../observe/alerting.md)

Details: [FINOPS_PRICING.md](../../../features/FINOPS_PRICING.md).
