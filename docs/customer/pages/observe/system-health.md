# System Health

## Purpose

Platform health dashboard — control-plane and Zeus-related component pulse for operators and admins.

## When to use it

- Morning check / after upgrades
- Correlate “UI slow” with backend or dependency health
- Decide whether an incident is cluster-wide or VM-local

## How to get there

- Route: `/system-health`
- Nav: **Observe → System Health** · workspace **Monitoring**

## Operate from the console (UX)

1. Open `/system-health` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Platform health dashboard — control-plane and Zeus-related component pulse for operators and admins.
3. Filter firing vs resolved; open an incident or alert for guided remediation.
4. Jump to related VMs/pods/nodes from the detail panel.
5. Silence only with an expiry when paging must pause — keep the alert visible in-ledger.
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Platform health dashboard — control-plane and Zeus-related component pulse for operators and admins.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [Home](../core/home.md)
- [Incidents](incidents.md)
- [Alerts](../../PAGE_INDEX.md) — `/alerting`
