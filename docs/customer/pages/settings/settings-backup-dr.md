# Settings — Backup & DR

## Purpose

Configuration entry points for Velero backups and disaster recovery, linking settings to the operational backup centers.

## When to use it

- Verify Velero is installed and wired before promising backup coverage
- Reach the backups or DR center quickly during a drill
- Check DR configuration ahead of an audit

## How to get there

- Route: `/settings/backup-dr`
- Nav: **Settings → Backup / DR**
- Related: `/velero`, `/backup-dr`, `/disaster-recovery`, `/backup-wizard`

## Operate from the console (UX)

1. Open `/settings/backup-dr` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Configuration entry points for Velero backups and disaster recovery, linking settings to the operational backup centers.
3. Prefer dry-run / plan when the UI offers it before mutating production.
4. Start the wizard or job; watch progress and history panels.
5. Confirm completion on the target inventory (VMs, snapshots, backup store).
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Configuration entry points for Velero backups and disaster recovery, linking settings to the operati.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [Settings overview](./settings.md)
- [Velero](../run/velero.md)
- [Backup Wizard](../run/backup-wizard.md)
- [Backup / DR center](../centers/backup-dr.md)
- [Snapshots](../run/snapshots.md)
