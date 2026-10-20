# Monitoring Targets

## Purpose

Inventory of Prometheus Operator objects in the cluster — ServiceMonitors, Prometheus instances, and PrometheusRule groups — plus high-level monitoring stats.

## When to use it

- Verify scrape coverage after installing kube-prometheus or similar
- Open a ServiceMonitor or PrometheusRule detail before changing GitOps
- Confirm Prometheus CRs exist and note external URLs
- Correlate missing metrics with missing ServiceMonitors

## How to get there

- Route: `/monitoring`
- Nav: **Observe → Monitoring Targets**
- Related: `/alerting?tab=prometheus`, `/custom-metrics`, `/vm-monitor`

## Operate from the console (UX)

1. Open `/monitoring` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Inventory of Prometheus Operator objects in the cluster — ServiceMonitors, Prometheus instances, and PrometheusRule grou….
3. Filter firing vs resolved; open an incident or alert for guided remediation.
4. Jump to related VMs/pods/nodes from the detail panel.
5. Silence only with an expiry when paging must pause — keep the alert visible in-ledger.
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Inventory of Prometheus Operator objects in the cluster — ServiceMonitors, Prometheus instances, and.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [VM Monitor](./vm-monitor.md)
- [Custom Metrics](./custom-metrics.md)
- [System Health](./system-health.md)
