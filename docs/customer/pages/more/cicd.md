# CI/CD

## Purpose

Pipeline inventory and run history with on-demand trigger controls for cluster-integrated CI/CD definitions.

## When to use it

- See which pipelines exist and their last-run status
- Trigger a pipeline manually after a config or image change
- Review recent runs, duration, commit SHA, and trigger type
- Correlate delivery work with Helm or progressive rollouts

## How to get there

- Route: `/cicd`
- Nav: **More → Delivery → CI/CD** (integrate tier)
- Related: `/progressive-delivery`, `/deployment-strategies`, `/gitops`

## Operate from the console (UX)

1. Open `/cicd` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Pipeline inventory and run history with on-demand trigger controls for cluster-integrated CI/CD definitions.
3. Use the center’s primary CTA (create, scan, open workbench, ask Zeus when reasoning is required).
4. Deterministic navigation and filters call the router directly — do not round-trip those through Ask Zeus.
5. Pin frequent pages to Favorites (`/favorites`).
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Pipeline inventory and run history with on-demand trigger controls for cluster-integrated CI/CD defi.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [Progressive Delivery](./progressive-delivery.md)
- [Deployment Strategies](./deployment-strategies.md)
- [GitOps Sync](../../PAGE_INDEX.md) — `/gitops`
