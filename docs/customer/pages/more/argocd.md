# ArgoCD

## Purpose

Read-only dashboard of Argo CD Applications and Projects — sync and health status for GitOps workloads in the cluster.

## When to use it

- Verify Application sync after a Git merge
- Find OutOfSync or degraded apps quickly
- Confirm Argo CD is installed before relying on GitOps stats elsewhere
- Cross-check with the GitOps VM sync view

## How to get there

- Route: `/argocd`
- Nav: **More → Insights → ArgoCD** (integrate tier)
- Related: `/gitops`

## Operate from the console (UX)

1. Open `/argocd` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Read-only dashboard of Argo CD Applications and Projects — sync and health status for GitOps workloads in the cluster.
3. Use the center’s primary CTA (create, scan, open workbench, ask Zeus when reasoning is required).
4. Deterministic navigation and filters call the router directly — do not round-trip those through Ask Zeus.
5. Pin frequent pages to Favorites (`/favorites`).
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Read-only dashboard of Argo CD Applications and Projects — sync and health status for GitOps workloa.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [GitOps](./gitops.md)
- [VMs](../core/vms.md)
