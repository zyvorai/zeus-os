# Events

## Purpose

Live Kubernetes event browser — type, reason, object, message, namespace, count, and age — for correlating cluster noise with VM or workload symptoms.

## When to use it

- Investigate FailedScheduling, FailedMount, or Warning storms
- Filter events to one namespace during a rollout
- Switch to search when the table is too noisy
- Confirm whether a VM issue is backed by recent cluster events

## How to get there

- Route: `/events`
- Nav: **Observe → Events**
- Related: `/incidents`, `/system-health`

## Tabs

One route, tabs in the URL (`?tab=`), so links and the back button work:

| Tab | Deep link | What it is |
|-----|-----------|------------|
| Events | `/events` | Live event table, search, and **Analysis** (patterns and anomalies) as modes of the same tab (`?view=search`, `?view=analysis`) |
| Timeline | `/events?tab=timeline` | Cross-engine timeline with bookmarks and export; empty until `ZEUS_OS_EVENT_STORE` is enabled or a remediation has run |
| Audit log | `/events?tab=audit` | Searchable operator/audit trail with CSV export |
| Gantt | `/events?tab=gantt` | VM lifecycle Gantt built from Kubernetes events |
| Scheduled ops | `/events?tab=scheduled` | Per-VM lifecycle actions on a cron expression |

## Operate from the console (UX)

1. Open `/events` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Live Kubernetes event browser — type, reason, object, message, namespace, count, and age — for correlating cluster noise….
3. Filter firing vs resolved; open an incident or alert for guided remediation.
4. Jump to related VMs/pods/nodes from the detail panel.
5. Silence only with an expiry when paging must pause — keep the alert visible in-ledger.
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Live Kubernetes event browser — type, reason, object, message, namespace, count, and age — for corre.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [Incidents](./incidents.md)
- [System Health](./system-health.md)
