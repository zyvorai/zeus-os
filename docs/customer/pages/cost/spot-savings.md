# Spot Savings

## Purpose

Nav alias for the Optimization Center. There is no separate Spot Savings page — the link opens resource optimization recommendations and savings tracking.

## When to use it

- Follow Cost → Spot Savings when hunting for spend reductions
- Open savings recommendations from an older bookmark at `/spot-savings`
- Continue into apply / rightsizing-style actions on Optimization

## How to get there

- Route: `/spot-savings` (redirects to `/optimization`)
- Nav: **Cost → Spot Savings**
- Related: `/optimization`, `/costs`, `/rightsizing`, `/cost-intelligence`

## Operate from the console (UX)

1. Open `/spot-savings` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Nav alias for the Optimization Center. There is no separate Spot Savings page — the link opens resource optimization rec….
3. Select the time range and scope (cluster / namespace / tenant).
4. Drill from rollup → workload; export or create a budget/alert if the page offers it.
5. Cross-check rightsizing recommendations before resizing production VMs.
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Nav alias for the Optimization Center. There is no separate Spot Savings page — the link opens resou.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [Optimization](../../PAGE_INDEX.md) — `/optimization`
- [Costs](./costs.md)
- [Rightsizing](./rightsizing.md)
- [Cost Intelligence](./cost-intelligence.md)

