# Disaster Recovery

## Purpose

Disaster Recovery Center — visual DR plans, RPO/RTO targets, failover test scheduling, and step runbooks for day-2 resilience.

## When to use it

- Maintain DR plans and objective targets
- Schedule or record failover tests
- Walk plan steps during a drill or real event
- Coordinate with Velero backups before declaring readiness

## How to get there

- Route: `/disaster-recovery`
- Nav: **More → Resilience → Disaster Recovery** (integrate tier)
- Related: `/velero`, `/multi-cluster`, `/snapshots`

## Operate from the console (UX)

1. Open `/disaster-recovery` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Disaster Recovery Center — visual DR plans, RPO/RTO targets, failover test scheduling, and step runbooks for day-2 resil….
3. Use the center’s primary CTA (create, scan, open workbench, ask Zeus when reasoning is required).
4. Deterministic navigation and filters call the router directly — do not round-trip those through Ask Zeus.
5. Pin frequent pages to Favorites (`/favorites`).
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Disaster Recovery Center — visual DR plans, RPO/RTO targets, failover test scheduling, and step runb.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [Velero](../run/velero.md)
- [Multi-Cluster](./multi-cluster.md)
- [Snapshots](../run/snapshots.md)
- [Incidents](../observe/incidents.md)
