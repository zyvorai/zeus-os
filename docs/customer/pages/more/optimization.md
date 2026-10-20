# Optimization

## Purpose

Resource optimization recommendations and estimated savings — review rightsizing suggestions and apply supported hotplug/shape changes when enabled.

## When to use it

- Periodic waste and oversize sweeps
- After Cost Intelligence flags expensive VMs
- Track which recommendations were already applied
- Replace older `/rightsizing` and `/spot-savings` bookmarks (those routes redirect here)

## How to get there

- Route: `/optimization`
- Nav: **More → Insights → Optimization**
- Related: `/rightsizing` (redirect), `/spot-savings` (redirect), `/cost-intelligence`

## Operate from the console (UX)

1. Open `/optimization` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Resource optimization recommendations and estimated savings — review rightsizing suggestions and apply supported hotplug….
3. Use the center’s primary CTA (create, scan, open workbench, ask Zeus when reasoning is required).
4. Deterministic navigation and filters call the router directly — do not round-trip those through Ask Zeus.
5. Pin frequent pages to Favorites (`/favorites`).
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Resource optimization recommendations and estimated savings — review rightsizing suggestions and app.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [Rightsizing](../cost/rightsizing.md)
- [VMs](../core/vms.md)
- [Anomaly Detector](./anomaly-detector.md)
- [Cost Intelligence](../../PAGE_INDEX.md) — `/cost-intelligence`
