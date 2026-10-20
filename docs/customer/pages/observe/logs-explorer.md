# Logs Explorer

## Purpose

On-demand log search across pods in a namespace — query text, severity filter, and optional live tail — for day-2 debugging from the dashboard.

## When to use it

- Search for `error`, `OOMKilled`, or a pod name during an incident
- Narrow to one namespace before opening a terminal
- Live-tail a query while reproducing a failure
- Confirm whether a VM-adjacent pod is logging failures

## How to get there

- Route: `/logs-explorer`
- Nav: **Observe → Logs Explorer**
- Related: `/containers`, `/pods`, `/events?view=analysis`

## Operate from the console (UX)

1. Open `/logs-explorer` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: On-demand log search across pods in a namespace — query text, severity filter, and optional live tail — for day-2 debugg….
3. Filter firing vs resolved; open an incident or alert for guided remediation.
4. Jump to related VMs/pods/nodes from the detail panel.
5. Silence only with an expiry when paging must pause — keep the alert visible in-ledger.
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: On-demand log search across pods in a namespace — query text, severity filter, and optional live tai.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [Containers](./containers.md)
- [Pods](../cluster/pods.md)
- [APM](./apm.md)
- [Events](./events.md)
