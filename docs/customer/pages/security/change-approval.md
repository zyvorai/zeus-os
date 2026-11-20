# Change Approval

## Purpose

A review queue for VM changes: destructive requests wait for a human approver, non-destructive ones are auto-approved, and every decision is recorded with a comment and a timestamp.

## When to use it

- Require sign-off before a VM is deleted or migrated
- Work through the pending queue as the on-call approver
- Record why a change was allowed or refused
- Show an auditor the decision history for a change window

## How to get there

- Route: `/change-approval`
- Nav: **Security -> Change Approval**
- Related: `/events?tab=audit`, `/security`, `/vms`

## Operate from the console (UX)

1. Open `/change-approval` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: A review queue for VM changes: destructive requests wait for a human approver, non-destructive ones are auto-approved, a….
3. Filter findings / policies by severity or namespace.
4. Open a row for evidence and remediation; use change-approval gates when enabled.
5. Export or acknowledge as your role allows — do not mute crit without a live condition handled.
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: A review queue for VM changes: destructive requests wait for a human approver, non-destructive ones .
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [Security](./security.md)
- [Events (Audit log tab)](../observe/events.md)
- [Users](./users.md)
- [VMs](../core/vms.md)
- [Live Migrations](../run/migrations.md)
