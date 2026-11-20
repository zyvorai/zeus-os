# GitOps

## Purpose

Compare desired versus actual VM power state, show Flux/Argo cluster stats, and sync power-status drift back toward the intended running/stopped state.

## When to use it

- After GitOps or pipeline updates that should change VM power
- Audit drift between declared and live VM status
- Confirm Flux GitRepositories / Kustomizations are present
- Bulk-correct power-status drifts when safe

## How to get there

- Route: `/gitops`
- Nav: **More → Insights → GitOps** (integrate tier)
- Related: `/argocd`, `/vms`

## Operate from the console (UX)

1. Open `/gitops` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Compare desired versus actual VM power state, show Flux/Argo cluster stats, and sync power-status drift back toward the ….
3. Prefer dry-run / plan when the UI offers it before mutating production.
4. Start the wizard or job; watch progress and history panels.
5. Confirm completion on the target inventory (VMs, snapshots, backup store).
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Compare desired versus actual VM power state, show Flux/Argo cluster stats, and sync power-status dr.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [ArgoCD](./argocd.md)
- [VMs](../core/vms.md)
- [VMIs](../core/vmis.md)
