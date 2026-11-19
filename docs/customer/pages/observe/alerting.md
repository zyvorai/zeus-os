# Alerts

## Purpose

Zeus-native alerting console — active fired alerts, threshold rules, history, and webhook destinations — separate from PrometheusRule CRDs in Alerting V2.

## When to use it

- Triage currently firing Zeus alerts by severity
- Create or edit CPU, memory, restart, or node-pressure rules
- Acknowledge or resolve noise while investigating
- Wire Slack or other HTTPS webhooks for notifications
- Review history filtered by severity

## How to get there

- Route: `/alerting`
- Nav: **Observe → Alerts**
- Related: `/incidents`, `/monitoring`

## Tabs

One route, tabs in the URL (`?tab=`):

| Tab | Deep link | What it is |
|-----|-----------|------------|
| Active alerts | `/alerting` | Alerts fired by the Zeus alerting engine |
| Rules | `/alerting?tab=rules` | Zeus-native alert rules |
| History | `/alerting?tab=history` (`&severity=warning`) | Past alerts |
| Webhooks | `/alerting?tab=webhooks` | Alert webhook destinations |
| Channels | `/alerting?tab=channels` | Notification channels (Slack, email, webhook, PagerDuty), test sends, delivery history |
| Prometheus | `/alerting?tab=prometheus` | PrometheusRule-CRD rules, Alertmanager firing alerts, and the rule-group editor (`?view=rules|firing|editor`) |

## Operate from the console (UX)

1. Open `/alerting` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Zeus-native alerting console — active fired alerts, threshold rules, history, and webhook destinations — separate from P….
3. Filter firing vs resolved; open an incident or alert for guided remediation.
4. Jump to related VMs/pods/nodes from the detail panel.
5. Silence only with an expiry when paging must pause — keep the alert visible in-ledger.
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Zeus-native alerting console — active fired alerts, threshold rules, history, and webhook destinatio.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [Incidents](./incidents.md)
- [Monitoring Targets](./monitoring.md)
- [System Health](./system-health.md)
