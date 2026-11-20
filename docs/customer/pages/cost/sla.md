# SLA Dashboard

## Purpose

Live VM up/down posture plus configurable SLO targets (uptime % and latency). Historical uptime and error budget are not synthesized without availability history.

## When to use it

- Check how many VMs are currently up vs down
- Define or edit SLO targets for production services
- Align operators and FinOps on declared SLO numbers
- Spot stopped or failed VMs during an incident

## How to get there

- Route: `/sla`
- Nav: **Cost → SLA Dashboard**
- Related: `/vms`, `/system-health`, `/incidents`

## Operate from the console (UX)

1. Open `/sla` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Live VM up/down posture plus configurable SLO targets (uptime % and latency). Historical uptime and error budget are not….
3. Select the time range and scope (cluster / namespace / tenant).
4. Drill from rollup → workload; export or create a budget/alert if the page offers it.
5. Cross-check rightsizing recommendations before resizing production VMs.
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Live VM up/down posture plus configurable SLO targets (uptime % and latency). Historical uptime and .
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [Virtual Machines](../core/vms.md)
- [System Health](../observe/system-health.md)
- [Costs](./costs.md)
- [Incidents](../../PAGE_INDEX.md) — `/incidents`

