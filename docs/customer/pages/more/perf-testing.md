# Performance Testing

## Purpose

List and run performance tests defined in the cluster, with live metrics (users/pods tracked, estimated RPS, error rate, latency).

## When to use it

- Load-test a service URL before a release
- Compare latency and error rate under concurrent users
- Validate capacity after rightsizing or placement changes
- Operationalize tests stored as labeled ConfigMaps

## How to get there

- Route: `/perf-testing`
- Nav: **More → Resilience → Performance Testing**
- Related: `/chaos-engineering`, `/optimization`

## Operate from the console (UX)

1. Open `/perf-testing` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: List and run performance tests defined in the cluster, with live metrics (users/pods tracked, estimated RPS, error rate,….
3. Use the center’s primary CTA (create, scan, open workbench, ask Zeus when reasoning is required).
4. Deterministic navigation and filters call the router directly — do not round-trip those through Ask Zeus.
5. Pin frequent pages to Favorites (`/favorites`).
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: List and run performance tests defined in the cluster, with live metrics (users/pods tracked, estima.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [Chaos Engineering](./chaos-engineering.md)
- [Optimization](./optimization.md)
- [System Health](../observe/system-health.md)
