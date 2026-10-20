# Helm Releases

## Purpose

List, install, upgrade history, rollback, and uninstall Helm releases, and manage chart repositories on the cluster.

## When to use it

- Inventory releases by namespace and status
- Install a chart from a configured repository
- Inspect revision history and roll back a bad upgrade
- Add or remove Helm repositories used by the control plane

## How to get there

- Route: `/helm`
- Nav: **More → Delivery → Helm Releases**
- Related: `/operators`, `/kustomize`, `/cicd`

## Operate from the console (UX)

1. Open `/helm` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: List, install, upgrade history, rollback, and uninstall Helm releases, and manage chart repositories on the cluster.
3. Use the center’s primary CTA (create, scan, open workbench, ask Zeus when reasoning is required).
4. Deterministic navigation and filters call the router directly — do not round-trip those through Ask Zeus.
5. Pin frequent pages to Favorites (`/favorites`).
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: List, install, upgrade history, rollback, and uninstall Helm releases, and manage chart repositories.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [Operators](./operators.md)
- [Kustomize](./kustomize.md)
- [Deployment Strategies](./deployment-strategies.md)
