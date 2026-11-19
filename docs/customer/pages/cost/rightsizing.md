# Rightsizing

## Purpose

Recommendations for idle, oversized, or orphaned resources — turn Cost Intelligence into concrete shape changes.

## When to use it

- After reviewing expensive VMs
- Periodic waste sweeps
- Before purchasing more cluster capacity

## How to get there

- Route: `/rightsizing`
- Nav: **More → Insights → Rightsizing** (also linked from Cost views)

## Operate from the console (UX)

1. Open `/rightsizing` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Recommendations for idle, oversized, or orphaned resources — turn Cost Intelligence into concrete shape changes.
3. Select the time range and scope (cluster / namespace / tenant).
4. Drill from rollup → workload; export or create a budget/alert if the page offers it.
5. Cross-check rightsizing recommendations before resizing production VMs.
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Recommendations for idle, oversized, or orphaned resources — turn Cost Intelligence into concrete sh.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [Cost Intelligence](cost-intelligence.md)
- [Instance types](../core/instance-types.md)
- [Optimization](../../PAGE_INDEX.md) — `/optimization`
