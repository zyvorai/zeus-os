# Restore Wizard

## Purpose

Guided Velero restore — select a completed backup, configure target namespace and PV restore, then monitor restore phase to completion.

## When to use it

- Restore after accidental deletion or failed upgrade
- Cross-namespace restore when `?crossNamespace=1` is set
- Prefill a known backup with `?backup=`
- Run a DR drill from Backup & DR

## How to get there

- Route: `/restore-wizard`
- Nav: **Command palette / deep link** (also from Backup & DR)
- Related: `/backup-dr`, `/velero`, `/backup-wizard`

## Operate from the console (UX)

1. Open `/restore-wizard` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Guided Velero restore — select a completed backup, configure target namespace and PV restore, then monitor restore phase….
3. Use the center’s primary CTA (create, scan, open workbench, ask Zeus when reasoning is required).
4. Deterministic navigation and filters call the router directly — do not round-trip those through Ask Zeus.
5. Pin frequent pages to Favorites (`/favorites`).
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Guided Velero restore — select a completed backup, configure target namespace and PV restore, then m.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [Backup & DR](./backup-dr.md)
- [Velero](../run/velero.md)
- [Backup Wizard](../run/backup-wizard.md)
