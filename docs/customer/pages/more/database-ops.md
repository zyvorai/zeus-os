# Database Ops

## Purpose

Day-2 view of database instances and their backups — status, storage, endpoints, and connection details for operator copy-out.

## When to use it

- Inventory databases by type, version, and namespace
- Check running vs unhealthy instances at a glance
- Copy endpoint, port, or username for troubleshooting
- Review recent database backups and sizes

## How to get there

- Route: `/database-ops`
- Nav: **More → Delivery → Database Ops**
- Related: `/backup-dr`, `/velero`, `/applications`

## Operate from the console (UX)

1. Open `/database-ops` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Day-2 view of database instances and their backups — status, storage, endpoints, and connection details for operator cop….
3. Prefer dry-run / plan when the UI offers it before mutating production.
4. Start the wizard or job; watch progress and history panels.
5. Confirm completion on the target inventory (VMs, snapshots, backup store).
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Day-2 view of database instances and their backups — status, storage, endpoints, and connection deta.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [Backup & DR](../centers/backup-dr.md)
- [Velero](../run/velero.md)
- [Application Center](../centers/applications.md)
