# Backup & DR

## Purpose

Recovery Theatre hub — backup stats plus shortcuts to Velero, restore, snapshots, DR, and backup wizards.

## When to use it

- See total, completed, and failed backups at a glance
- Launch Velero, Restore Wizard, or Backup Wizard
- Open Disaster Recovery plans and DR settings (RPO/RTO)
- Start protection when no backups are detected yet

## How to get there

- Route: `/backup-dr`
- Nav: **Monitoring → Backup & DR** (display name Recovery Theatre)
- Related: `/velero`, `/restore-wizard`, `/backup-wizard`, `/disaster-recovery`

## Operate from the console (UX)

1. Open `/backup-dr` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Recovery Theatre hub — backup stats plus shortcuts to Velero, restore, snapshots, DR, and backup wizards.
3. Prefer dry-run / plan when the UI offers it before mutating production.
4. Start the wizard or job; watch progress and history panels.
5. Confirm completion on the target inventory (VMs, snapshots, backup store).
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Recovery Theatre hub — backup stats plus shortcuts to Velero, restore, snapshots, DR, and backup wiz.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [Velero](../run/velero.md)
- [Restore Wizard](./restore-wizard.md)
- [Backup Wizard](../run/backup-wizard.md)
- [Snapshots](../run/snapshots.md)
