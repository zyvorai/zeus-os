# Blueprints

## Purpose

Blueprint Marketplace for one-click application stacks (for example Windows AD, RDS, SQL, IIS, jump boxes) registered in the cluster.

## When to use it

- Deploy a multi-resource stack into a target namespace
- Register a new blueprint shell for later parameterization
- Jump to Image Factory for golden-image builds
- Deploy multi-VM blueprints as a VMIRS fleet when offered

## How to get there

- Route: `/blueprints`
- Nav: **Cluster → Blueprints**
- Related: `/image-factory`, `/vmirs`

## Operate from the console (UX)

1. Open `/blueprints` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Blueprint Marketplace for one-click application stacks (for example Windows AD, RDS, SQL, IIS, jump boxes) registered in….
3. Use namespace / label filters; open an object for inspector details.
4. Mutations (drain, resize PVC, attach NAD) go through confirm sheets — wait for status refresh.
5. If empty: broaden namespace filter, confirm RBAC, and that the cluster API is reachable.
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Blueprint Marketplace for one-click application stacks (for example Windows AD, RDS, SQL, IIS, jump .
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [Image Factory](./image-factory.md)
- [Templates](./templates.md)
- [VMs](../core/vms.md)
- [VM fleets](../../PAGE_INDEX.md) — `/vmirs`
