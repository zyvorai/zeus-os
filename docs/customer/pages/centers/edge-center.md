# Edge Center

## Purpose

Guidance hub for branch clusters, air-gapped operation, and sync or compliance posture tied to multi-cluster views.

## When to use it

- Orient on retail, factory, or remote office cluster patterns
- Review air-gap capabilities (offline images, local AI, license, audit export)
- Jump to Multi-cluster for sync status
- Open Advanced settings for edge-related options

## How to get there

- Route: `/edge-center`
- Nav: **Modules → Edge Center**
- Related: `/multi-cluster`, `/settings/advanced`

## Operate from the console (UX)

1. Open `/edge-center` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Guidance hub for branch clusters, air-gapped operation, and sync or compliance posture tied to multi-cluster views.
3. Use the center’s primary CTA (create, scan, open workbench, ask Zeus when reasoning is required).
4. Deterministic navigation and filters call the router directly — do not round-trip those through Ask Zeus.
5. Pin frequent pages to Favorites (`/favorites`).
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Guidance hub for branch clusters, air-gapped operation, and sync or compliance posture tied to multi.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [Multi-Cluster](../../PAGE_INDEX.md) — `/multi-cluster`
- [Settings](../settings/settings.md)
- [Identity Center](./identity-center.md)
