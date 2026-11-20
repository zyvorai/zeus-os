# Operations

## Purpose

One console for the recurring day-2 chores: alert rules, outbound webhooks, quotas, GPU inventory, backup and power and snapshot schedules, RBAC review, quick deploy, cluster context, and labels.

## When to use it

- Add an alert rule or check what is currently firing
- Wire a webhook so another system hears about Zeus OS events
- See which namespaces are close to their resource quota
- Create or remove a power schedule so dev VMs stop overnight
- Confirm what the current identity is allowed to do before a change window

## How to get there

- Route: `/operations` (the active tab is kept in the `?tab=` query parameter, so a tab is linkable)
- Nav: **Run -> Operations**
- Related: `/events?tab=scheduled`, `/snapshots`, `/alerting?tab=prometheus`, `/users`

## Operate from the console (UX)

1. Open `/operations` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the editorial intro, then pick a tab (`?tab=`) for alert rules, webhooks, quotas, GPU, schedules, or RBAC.
3. Prefer dry-run / plan when the UI offers it before mutating production.
4. Start the wizard or job; watch progress and history panels.
5. Confirm completion on the target inventory (VMs, snapshots, backup store).
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: One console for the recurring day-2 chores: alert rules, outbound webhooks, quotas, GPU inventory, b.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [Events (Scheduled ops tab)](../observe/events.md)
- [Snapshots](./snapshots.md)
- [Backup Wizard](./backup-wizard.md)
- [Users](../security/users.md)
- [Alerting (Prometheus tab)](../observe/alerting.md)
