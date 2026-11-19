# Operators

## Purpose

OLM inventory for ClusterServiceVersions, Subscriptions, OperatorGroups, CatalogSources, and InstallPlans with aggregate health stats.

## When to use it

- Confirm which operators are installed and their CSV phase
- Trace subscription upgrade state or catalog health
- Inspect OperatorGroups and InstallPlans that need approval
- Drill into CRDs and conditions for a stuck operator

## How to get there

- Route: `/operators`
- Nav: **More → Delivery → Operators**
- Related: `/helm`, `/kubernetes`, `/approvals`

## Operate from the console (UX)

1. Open `/operators` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: OLM inventory for ClusterServiceVersions, Subscriptions, OperatorGroups, CatalogSources, and InstallPlans with aggregate….
3. Use the center’s primary CTA (create, scan, open workbench, ask Zeus when reasoning is required).
4. Deterministic navigation and filters call the router directly — do not round-trip those through Ask Zeus.
5. Pin frequent pages to Favorites (`/favorites`).
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: OLM inventory for ClusterServiceVersions, Subscriptions, OperatorGroups, CatalogSources, and Install.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [Helm Releases](./helm.md)
- [Kubernetes Center](../centers/kubernetes.md)
- [Approvals](../centers/approvals.md)
