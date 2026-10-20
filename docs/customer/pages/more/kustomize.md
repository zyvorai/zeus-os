# Kustomize

## Purpose

Browse Kustomize bases and overlays, then preview the rendered diff before you apply changes outside the dashboard.

## When to use it

- Inventory overlays and which base each one builds on
- Count patches and see last-applied status per overlay
- Preview a diff for an overlay before a GitOps sync
- Orient new operators on how environments are layered

## How to get there

- Route: `/kustomize`
- Nav: **More → Delivery → Kustomize** (integrate tier)
- Related: `/iac`, `/gitops`, `/helm`

## Operate from the console (UX)

1. Open `/kustomize` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Browse Kustomize bases and overlays, then preview the rendered diff before you apply changes outside the dashboard.
3. Use the center’s primary CTA (create, scan, open workbench, ask Zeus when reasoning is required).
4. Deterministic navigation and filters call the router directly — do not round-trip those through Ask Zeus.
5. Pin frequent pages to Favorites (`/favorites`).
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Browse Kustomize bases and overlays, then preview the rendered diff before you apply changes outside.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [IaC](./iac.md)
- [Helm Releases](./helm.md)
- [GitOps Sync](../../PAGE_INDEX.md) — `/gitops`
