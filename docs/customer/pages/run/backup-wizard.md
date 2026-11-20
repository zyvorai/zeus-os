# Backup Wizard

## Purpose

Guided backup workflow for VMs / volumes — complementary to Velero and snapshot managers.

## When to use it

- Operator-driven one-shot backup
- When you want a checklist rather than raw Velero YAML
- Before major changes when Velero schedules are not enough

## How to get there

- Route: `/backup-wizard`
- Nav: **Run → Backup Wizard**
- Related: `/backup-dr`, `/disaster-recovery`

## Operate from the console (UX)

1. Open `/backup-wizard` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Guided backup workflow for VMs / volumes — complementary to Velero and snapshot managers.
3. Prefer dry-run / plan when the UI offers it before mutating production.
4. Start the wizard or job; watch progress and history panels.
5. Confirm completion on the target inventory (VMs, snapshots, backup store).
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Guided backup workflow for VMs / volumes — complementary to Velero and snapshot managers.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [Velero](velero.md)
- [Snapshots](snapshots.md)
- [Disaster Recovery](../../PAGE_INDEX.md) — `/disaster-recovery`
