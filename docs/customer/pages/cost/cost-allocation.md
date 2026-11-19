# Cost Allocation

## Purpose

Namespace-level chargeback view: estimated monthly cost rolled up by namespace, with CPU, memory, and storage share plus per-VM detail.

## When to use it

- Prepare showback or chargeback for app owners
- Compare namespace share of total spend
- Drill into which VMs drive a namespace’s bill
- Confirm unit rates used for the estimate

## How to get there

- Route: `/cost-allocation`
- Nav: **Cost → Cost Allocation**
- Related: `/chargeback` (redirects here), `/costs`, `/budget-alerts`

## Operate from the console (UX)

1. Open `/cost-allocation` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Namespace-level chargeback view: estimated monthly cost rolled up by namespace, with CPU, memory, and storage share plus….
3. Select the time range and scope (cluster / namespace / tenant).
4. Drill from rollup → workload; export or create a budget/alert if the page offers it.
5. Cross-check rightsizing recommendations before resizing production VMs.
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Namespace-level chargeback view: estimated monthly cost rolled up by namespace, with CPU, memory, an.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [Costs](./costs.md)
- [Cost Intelligence](./cost-intelligence.md)
- [Chargeback](./chargeback.md) — alias to this page
- [Budget Alerts](./budget-alerts.md)
