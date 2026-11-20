# Velero

## Purpose

Velero-backed backup and restore operations for cluster and VM-related resources.

## When to use it

- Scheduled cluster/namespace backups
- Restore after accidental deletion
- DR drills with Backup / DR centers

## How to get there

- Route: `/velero`
- Nav: **More → Resilience → Velero** (integrate tier)
- Related: `/backup-dr`, Restore Wizard `/restore-wizard`

## Operate from the console (UX)

1. Open `/velero` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Velero-backed backup and restore operations for cluster and VM-related resources.
3. Prefer dry-run / plan when the UI offers it before mutating production.
4. Start the wizard or job; watch progress and history panels.
5. Confirm completion on the target inventory (VMs, snapshots, backup store).
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Velero-backed backup and restore operations for cluster and VM-related resources.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [Backup Wizard](backup-wizard.md)
- [Snapshots](snapshots.md)
- [Disaster Recovery](../../PAGE_INDEX.md)
