# Cluster Upgrade

## Purpose

Version awareness and an upgrade checklist for Kubernetes and KubeVirt — plus VLCM rollout controls — so operators plan upgrades without skipping critical backups and drains.

## When to use it

- Before upgrading Kubernetes or KubeVirt
- Track checklist progress across a maintenance window
- Review VLCM / operator rollout status alongside the plan
- Reset checklist progress after a completed upgrade

## How to get there

- Route: `/cluster-upgrade`
- Nav: **More → Resilience → Cluster Upgrade**
- Related: `/nodes`, `/velero`, `/disaster-recovery`

## Operate from the console (UX)

1. Open `/cluster-upgrade` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Version awareness and an upgrade checklist for Kubernetes and KubeVirt — plus VLCM rollout controls — so operators plan ….
3. Use the center’s primary CTA (create, scan, open workbench, ask Zeus when reasoning is required).
4. Deterministic navigation and filters call the router directly — do not round-trip those through Ask Zeus.
5. Pin frequent pages to Favorites (`/favorites`).
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Version awareness and an upgrade checklist for Kubernetes and KubeVirt — plus VLCM rollout controls .
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [Nodes](../cluster/nodes.md)
- [Velero](../run/velero.md)
- [Disaster Recovery](./disaster-recovery.md)
- [Migrations](../run/migrations.md)
