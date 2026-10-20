# Snapshots

## Purpose

Create and manage VM snapshots (on-demand and scheduled) for point-in-time recovery.

## When to use it

- Before risky upgrades or config changes
- Enforce periodic snapshot policy
- Prepare for Restore Wizard recovery

## How to get there

- Routes: `/snapshots`, `/snapshot-manager`
- Nav: **Run → Snapshots** / **Snapshot Manager**

## Operate from the console (UX)

1. Open `/snapshots` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Create and manage VM snapshots (on-demand and scheduled) for point-in-time recovery.
3. Prefer dry-run / plan when the UI offers it before mutating production.
4. Start the wizard or job; watch progress and history panels.
5. Confirm completion on the target inventory (VMs, snapshots, backup store).
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Create and manage VM snapshots (on-demand and scheduled) for point-in-time recovery.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [Backup Wizard](backup-wizard.md)
- [Velero](velero.md)
- [VM workbench](../core/vm-workbench.md)
