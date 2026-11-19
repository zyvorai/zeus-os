# IaC

## Purpose

Infrastructure-as-code resource inventory with drift detection and a sync action for IaC-managed objects Zeus OS can see.

## When to use it

- List IaC-managed resources by provider, type, and sync status
- Investigate drift (expected vs actual field values)
- Trigger a sync after fixing source of truth in Git or Terraform
- Confirm how many resources are synced versus drifted

## How to get there

- Route: `/iac`
- Nav: **More → Delivery → IaC** (integrate tier)
- Related: `/kustomize`, `/gitops`, `/developer-center`

## Operate from the console (UX)

1. Open `/iac` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Infrastructure-as-code resource inventory with drift detection and a sync action for IaC-managed objects Zeus OS can see.
3. Use the center’s primary CTA (create, scan, open workbench, ask Zeus when reasoning is required).
4. Deterministic navigation and filters call the router directly — do not round-trip those through Ask Zeus.
5. Pin frequent pages to Favorites (`/favorites`).
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Infrastructure-as-code resource inventory with drift detection and a sync action for IaC-managed obj.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [Kustomize](./kustomize.md)
- [Developer Center](../centers/developer-center.md)
- [GitOps Sync](../../PAGE_INDEX.md) — `/gitops`
