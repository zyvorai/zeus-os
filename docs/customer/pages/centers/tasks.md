# Task Center

## Purpose

Long-running operations inbox — migrations, backups, and platform jobs with status, progress, and cancel when supported.

## When to use it

- Watch async work after a migration or backup starts
- Filter to active, running, or failed tasks via `?status=`
- Cancel a stuck task when the API allows
- Jump to the related VM from a task row

## How to get there

- Route: `/tasks`
- Nav: **Command palette / deep link** (also linked from Kubernetes Center)
- Related: `/migrations`, `/backup-dr`, `/vms`

## Operate from the console (UX)

1. Open `/tasks` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Long-running operations inbox — migrations, backups, and platform jobs with status, progress, and cancel when supported.
3. Use the center’s primary CTA (create, scan, open workbench, ask Zeus when reasoning is required).
4. Deterministic navigation and filters call the router directly — do not round-trip those through Ask Zeus.
5. Pin frequent pages to Favorites (`/favorites`).
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Long-running operations inbox — migrations, backups, and platform jobs with status, progress, and ca.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [Live Migrations](../run/migrations.md)
- [Backup & DR](./backup-dr.md)
- [Virtual Machines](../core/vms.md)
