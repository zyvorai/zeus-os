# Cost Estimator

## Purpose

What-if cost calculator for planned VM fleets: adjust count, shape, and unit prices to estimate monthly and annual spend (labs-tier page).

## When to use it

- Size a new project before provisioning
- Compare CPU / memory / storage cost drivers
- Sanity-check a quote against cluster unit rates
- Copy an estimate for planning docs

## How to get there

- Route: `/cost-estimator`
- Nav: **Cost → Cost Estimator** (labs)
- Related: `/costs`, `/cost-allocation`, `/instance-types`

## Operate from the console (UX)

1. Open `/cost-estimator` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: What-if cost calculator for planned VM fleets: adjust count, shape, and unit prices to estimate monthly and annual spend….
3. Select the time range and scope (cluster / namespace / tenant).
4. Drill from rollup → workload; export or create a budget/alert if the page offers it.
5. Cross-check rightsizing recommendations before resizing production VMs.
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: What-if cost calculator for planned VM fleets: adjust count, shape, and unit prices to estimate mont.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [Costs](./costs.md)
- [Cost Allocation](./cost-allocation.md)
- [Instance types](../core/instance-types.md)
- [Cost Intelligence](./cost-intelligence.md)
