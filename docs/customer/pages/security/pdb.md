# PDB

## Purpose

Shows every PodDisruptionBudget in the cluster and whether it currently permits any voluntary disruption — the fastest way to know if a drain will proceed or stall.

## When to use it

- Pre-flight a node drain or rolling upgrade
- Diagnose an eviction that is hanging with no progress
- Confirm a critical workload actually has a PDB protecting it
- Find budgets sitting below their desired healthy count

## How to get there

- Route: `/pdb`
- Nav: **Security -> PDB**
- Related: `/node-drain`, `/nodes`, `/affinity-rules`

## Operate from the console (UX)

1. Open `/pdb` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Shows every PodDisruptionBudget in the cluster and whether it currently permits any voluntary disruption — the fastest w….
3. Filter findings / policies by severity or namespace.
4. Open a row for evidence and remediation; use change-approval gates when enabled.
5. Export or acknowledge as your role allows — do not mute crit without a live condition handled.
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Shows every PodDisruptionBudget in the cluster and whether it currently permits any voluntary disrup.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [Node Drain](../run/node-drain.md)
- [Nodes](../cluster/nodes.md)
- [Affinity Rules](./affinity-rules.md)
- [Live Migrations](../run/migrations.md)
