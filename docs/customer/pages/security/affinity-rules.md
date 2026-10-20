# Affinity Rules

## Purpose

Surfaces where your affinity and anti-affinity placement intent is not being honoured — which rule is violated, which VMs are affected, and on which node.

## When to use it

- Verify an HA pair really is spread across separate nodes
- Investigate why a workload landed on an unexpected node
- Check placement compliance before or after a node drain
- Track the cluster's overall affinity compliance percentage

## How to get there

- Route: `/affinity-rules`
- Nav: **Security -> Affinity Rules**
- Related: `/nodes`, `/node-drain`, `/taints`

## Operate from the console (UX)

1. Open `/affinity-rules` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Surfaces where your affinity and anti-affinity placement intent is not being honoured — which rule is violated, which VM….
3. Filter findings / policies by severity or namespace.
4. Open a row for evidence and remediation; use change-approval gates when enabled.
5. Export or acknowledge as your role allows — do not mute crit without a live condition handled.
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Surfaces where your affinity and anti-affinity placement intent is not being honoured — which rule i.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [Nodes](../cluster/nodes.md)
- [Node Drain](../run/node-drain.md)
- [Pod Disruption Budgets](./pdb.md)
- [Live Migrations](../run/migrations.md)
- [Taints & Tolerations](../../PAGE_INDEX.md) — `/taints`
