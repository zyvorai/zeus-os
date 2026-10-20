# APM

## Purpose

Application performance dashboard for services, traces, and latency percentiles — when an APM backend is connected to Zeus OS.

## When to use it

- See which services are healthy vs degraded
- Search traces by service, operation, or trace id
- Watch p50 / p95 / p99 latency over time
- Confirm whether an incident is infra-only or also service-latency related

## How to get there

- Route: `/apm`
- Nav: **Observe → APM**
- Related: `/slo-manager`, `/logs-explorer`, `/custom-metrics`

## Operate from the console (UX)

1. Open `/apm` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Application performance dashboard for services, traces, and latency percentiles — when an APM backend is connected to Ze….
3. Filter firing vs resolved; open an incident or alert for guided remediation.
4. Jump to related VMs/pods/nodes from the detail panel.
5. Silence only with an expiry when paging must pause — keep the alert visible in-ledger.
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Application performance dashboard for services, traces, and latency percentiles — when an APM backen.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [SLO Manager](./slo-manager.md)
- [Logs Explorer](./logs-explorer.md)
- [Custom Metrics](./custom-metrics.md)
- [Incidents](./incidents.md)
