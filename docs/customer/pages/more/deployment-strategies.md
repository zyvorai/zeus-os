# Deployment Strategies

## Purpose

Define and run progressive delivery strategies (Rolling Update, Canary, Blue/Green, Recreate) against Kubernetes workloads, with execute and rollback controls.

## When to use it

- Create a reusable strategy with surge, canary weight, or analysis settings
- Execute a strategy against a target workload in a namespace
- Pause-aware deployments: track running, paused, succeeded, or failed status
- Roll back or delete a strategy that is no longer needed

## How to get there

- Route: `/deployment-strategies`
- Nav: **More → Delivery → Deployment Strategies**
- Related: `/progressive-delivery`, `/cicd`, `/helm`

## Operate from the console (UX)

1. Open `/deployment-strategies` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Define and run progressive delivery strategies (Rolling Update, Canary, Blue/Green, Recreate) against Kubernetes workloa….
3. Use the center’s primary CTA (create, scan, open workbench, ask Zeus when reasoning is required).
4. Deterministic navigation and filters call the router directly — do not round-trip those through Ask Zeus.
5. Pin frequent pages to Favorites (`/favorites`).
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Define and run progressive delivery strategies (Rolling Update, Canary, Blue/Green, Recreate) agains.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [Progressive Delivery](./progressive-delivery.md)
- [CI/CD](./cicd.md)
- [Helm Releases](./helm.md)
