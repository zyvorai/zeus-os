# Chargeback

## Purpose

Nav alias for namespace cost allocation / showback. There is no separate Chargeback UI — the link opens Cost Allocation.

## When to use it

- Reach chargeback-style reporting from the Cost menu
- Share a familiar “chargeback” bookmark that lands on live allocation data
- Jump from older docs or bookmarks that still use `/chargeback`

## How to get there

- Route: `/chargeback` (redirects to `/cost-allocation`)
- Nav: **Cost → Chargeback**
- Related: `/cost-allocation`, `/costs`, `/budget-alerts`

## Operate from the console (UX)

1. Open `/chargeback` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Nav alias for namespace cost allocation / showback. There is no separate Chargeback UI — the link opens Cost Allocation.
3. Select the time range and scope (cluster / namespace / tenant).
4. Drill from rollup → workload; export or create a budget/alert if the page offers it.
5. Cross-check rightsizing recommendations before resizing production VMs.
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Nav alias for namespace cost allocation / showback. There is no separate Chargeback UI — the link op.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [Cost Allocation](./cost-allocation.md)
- [Costs](./costs.md)
- [Budget Alerts](./budget-alerts.md)
- [Cost Intelligence](./cost-intelligence.md)
