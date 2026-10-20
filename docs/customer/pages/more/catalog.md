# Catalog

## Purpose

Infrastructure app catalog (Helm-oriented installs) for common day-2 stack pieces: browse categories, search apps, and trigger install.

## When to use it

- Install curated apps such as backup, monitoring, or registry stacks
- Browse by category or search publisher/name
- Check deploy counts and availability before installing
- Re-open the catalog after a failed install to retry

## How to get there

- Route: `/catalog`
- Nav: **More → Tools & settings → Catalog**
- Related: `/helm`, `/velero`, `/settings`

## Operate from the console (UX)

1. Open `/catalog` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Infrastructure app catalog (Helm-oriented installs) for common day-2 stack pieces: browse categories, search apps, and t….
3. Use the center’s primary CTA (create, scan, open workbench, ask Zeus when reasoning is required).
4. Deterministic navigation and filters call the router directly — do not round-trip those through Ask Zeus.
5. Pin frequent pages to Favorites (`/favorites`).
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Infrastructure app catalog (Helm-oriented installs) for common day-2 stack pieces: browse categories.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [Velero](../run/velero.md)
- [Settings](../settings/settings.md)
- [Topology](./topology.md)
- [Helm Releases](../../PAGE_INDEX.md) — `/helm`

