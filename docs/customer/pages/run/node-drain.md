# Node Drain

## Purpose

A guided five-step wizard for taking a node out of service safely: pick the node, see exactly which VMs will move and which will lose availability, choose a strategy, cordon and drain, then watch it finish.

## When to use it

- Patch, reboot, or decommission a worker node
- Evacuate VMs from a node showing hardware or disk problems
- Check the blast radius of maintenance before committing to a window
- Cancel a maintenance window and put a node back in service

## How to get there

- Route: `/node-drain` (accepts `?node=<name>`, which is how the **Drain wizard** links on the Nodes page arrive here)
- Nav: **Run -> Node Drain**
- Related: `/nodes`, `/migrations`, `/vms`

## Operate from the console (UX)

1. Open `/node-drain` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: A guided five-step wizard for taking a node out of service safely: pick the node, see exactly which VMs will move and wh….
3. Prefer dry-run / plan when the UI offers it before mutating production.
4. Start the wizard or job; watch progress and history panels.
5. Confirm completion on the target inventory (VMs, snapshots, backup store).
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: A guided five-step wizard for taking a node out of service safely: pick the node, see exactly which .
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [Nodes](../cluster/nodes.md)
- [Live Migrations](./migrations.md)
- [VMs](../core/vms.md)
- [Pod Disruption Budgets](../security/pdb.md)
