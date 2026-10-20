# Migration Command Center

## Purpose

VMware exit planning — migration waves, Transiva discovery handoff, preflight blockers, and wave readiness. Zeus OS does not perform VMware import itself.

## When to use it

- Plan waves (dev → production) before cutover
- Link a wave to a Transiva source reference
- Run preflight readiness on candidate VMs
- Open Transiva discovery in the sibling product

## How to get there

- Route: `/migration-factory`
- Nav: **Modules → Migration** (display name Migration Studio)
- Related: `/migrations`, Transiva / h2kvm (external)

## Operate from the console (UX)

1. Open `/migration-factory` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: VMware exit planning — migration waves, Transiva discovery handoff, preflight blockers, and wave readiness. Zeus OS does….
3. Prefer dry-run / plan when the UI offers it before mutating production.
4. Start the wizard or job; watch progress and history panels.
5. Confirm completion on the target inventory (VMs, snapshots, backup store).
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: VMware exit planning — migration waves, Transiva discovery handoff, preflight blockers, and wave rea.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [Live Migrations](../run/migrations.md)
- [Virtual Machines](../core/vms.md)
- [AI Center](../more/ai-center.md)
