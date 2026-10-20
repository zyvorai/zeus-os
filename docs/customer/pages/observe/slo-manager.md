# SLO Manager

## Purpose

Service level objective tracker — create availability-style objectives, watch met / burning / breached status, and refresh error-budget posture for the fleet.

## When to use it

- Define a target percent for a service or cluster KPI
- See how many SLOs are met, burning budget, or breached
- Refresh during an incident to check burn status
- Pair with APM or custom metrics when those backends feed indicators

## How to get there

- Route: `/slo-manager`
- Nav: **Observe → SLO Manager**
- Related: `/apm`, `/custom-metrics`, `/alerting`

## Operate from the console (UX)

1. Open `/slo-manager` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Service level objective tracker — create availability-style objectives, watch met / burning / breached status, and refre….
3. Filter firing vs resolved; open an incident or alert for guided remediation.
4. Jump to related VMs/pods/nodes from the detail panel.
5. Silence only with an expiry when paging must pause — keep the alert visible in-ledger.
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Service level objective tracker — create availability-style objectives, watch met / burning / breach.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [APM](./apm.md)
- [Custom Metrics](./custom-metrics.md)
- [Alerts](./alerting.md)
- [Incidents](./incidents.md)
