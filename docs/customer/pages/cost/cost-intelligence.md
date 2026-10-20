# Cost Intelligence

## Purpose

Per-VM and per-namespace spend visibility, trends, and FinOps entry points.

## When to use it

- Monthly cost review
- Chargeback conversations with app owners
- Find expensive outliers before rightsizing

## How to get there

- Route: `/cost-intelligence`
- Nav: **Cost → Cost Intelligence**
- Related: `/costs`, `/cost-allocation`, `/chargeback`, `/budget-alerts`

## Operate from the console (UX)

1. Open `/cost-intelligence` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Per-VM and per-namespace spend visibility, trends, and FinOps entry points.
3. Select the time range and scope (cluster / namespace / tenant).
4. Drill from rollup → workload; export or create a budget/alert if the page offers it.
5. Cross-check rightsizing recommendations before resizing production VMs.
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Per-VM and per-namespace spend visibility, trends, and FinOps entry points.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [Rightsizing](rightsizing.md)
- [Cost Allocation](../../PAGE_INDEX.md) — `/cost-allocation`
- [Capacity](../../PAGE_INDEX.md) — `/capacity`
