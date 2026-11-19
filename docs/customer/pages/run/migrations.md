# Live Migrations

## Purpose

Plan, dry-run, and execute live VM migrations between nodes with pre-flight checks and history.

## When to use it

- Node maintenance / drain
- Rebalance load across workers
- Evacuate VMs from a failing node

## How to get there

- Route: `/migrations`
- Nav: **Run → Live Migrations**
- Related: `/migration-factory` for batch campaigns (links Transiva/h2kvm where applicable)

## Operate from the console (UX)

1. Open `/migrations` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Plan, dry-run, and execute live VM migrations between nodes with pre-flight checks and history.
3. Prefer dry-run / plan when the UI offers it before mutating production.
4. Start the wizard or job; watch progress and history panels.
5. Confirm completion on the target inventory (VMs, snapshots, backup store).
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Plan, dry-run, and execute live VM migrations between nodes with pre-flight checks and history.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [Nodes](../cluster/nodes.md)
- [Node Drain](../../PAGE_INDEX.md) — `/node-drain`
- [VM Instances](../core/vmis.md)
