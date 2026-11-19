# Progressive Delivery

## Purpose

Operate canary deployments and progressive rollouts — traffic weight, health signals, promote, and rollback — from one delivery dashboard.

## When to use it

- Watch canary weight and success or latency signals during a release
- Promote a healthy rollout to full traffic
- Roll back a failing progressive deployment
- Confirm whether any canaries or rollouts are still in progress

## How to get there

- Route: `/progressive-delivery`
- Nav: **More → Delivery → Progressive Delivery**
- Related: `/deployment-strategies`, `/helm`, `/cicd`

## Operate from the console (UX)

1. Open `/progressive-delivery` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Operate canary deployments and progressive rollouts — traffic weight, health signals, promote, and rollback — from one d….
3. Use the center’s primary CTA (create, scan, open workbench, ask Zeus when reasoning is required).
4. Deterministic navigation and filters call the router directly — do not round-trip those through Ask Zeus.
5. Pin frequent pages to Favorites (`/favorites`).
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Operate canary deployments and progressive rollouts — traffic weight, health signals, promote, and r.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [Deployment Strategies](./deployment-strategies.md)
- [Helm Releases](./helm.md)
- [CI/CD](./cicd.md)
