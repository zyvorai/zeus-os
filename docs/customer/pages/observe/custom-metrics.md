# Custom Metrics

## Purpose

Dashboard for operator-defined metrics and their alert rules — create PromQL (or custom) configurations, then watch values and firing alerts.

## When to use it

- Track a metric that is not on the stock VM Monitor cards
- Add a PromQL-backed series for a tenant-specific KPI
- See which custom alert rules are firing
- Prototype a metric before promoting it into Alerting V2 / PrometheusRules

## How to get there

- Route: `/custom-metrics`
- Nav: **Observe → Custom Metrics**
- Related: `/alerting?tab=prometheus`, `/monitoring`, `/apm`

## Operate from the console (UX)

1. Open `/custom-metrics` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Dashboard for operator-defined metrics and their alert rules — create PromQL (or custom) configurations, then watch valu….
3. Filter firing vs resolved; open an incident or alert for guided remediation.
4. Jump to related VMs/pods/nodes from the detail panel.
5. Silence only with an expiry when paging must pause — keep the alert visible in-ledger.
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Dashboard for operator-defined metrics and their alert rules — create PromQL (or custom) configurati.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [Monitoring Targets](./monitoring.md)
- [APM](./apm.md)
- [SLO Manager](./slo-manager.md)
