# Incidents

## Purpose

Incident center with context and guided remediation — not just a raw alert dump.

## When to use it

- Triage an outage or degraded VM fleet
- Assign / track remediation steps
- Jump to War Room or chat when collaboration is needed

## How to get there

- Route: `/incidents`
- Nav: **Observe → Incidents**
- Related: `/incident-chat`, `/war-room`, `/incident-response` (wizard)

## Operate from the console (UX)

1. Open `/incidents` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the editorial hero and **Get the highlights** (critical / warnings / cluster readiness), then filter and open an incident.
3. Filter firing vs resolved; open an incident or alert for guided remediation.
4. Jump to related VMs/pods/nodes from the detail panel.
5. Silence only with an expiry when paging must pause — keep the alert visible in-ledger.
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Incident center with context and guided remediation — not just a raw alert dump.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [System Health](system-health.md)
- [Auto-Remediation](../../PAGE_INDEX.md) — `/auto-remediation`
- [Events](../../PAGE_INDEX.md) — `/events`
