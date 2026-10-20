# Widgets

## Purpose

Customizable dashboard widget grid (VM count, capacity, health, events, favorites, alerts) with layout persistence in the browser.

## When to use it

- Build a personal at-a-glance operations board
- Add or remove widgets without changing the Home layout for everyone
- Reorder cards to match your shift workflow
- Reset to the default widget set

## How to get there

- Route: `/widgets`
- Nav: **More → Tools & settings → Widgets**
- Related: `/favorites`, `/`, `/system-health`

## Operate from the console (UX)

1. Open `/widgets` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Customizable dashboard widget grid (VM count, capacity, health, events, favorites, alerts) with layout persistence in th….
3. Use the center’s primary CTA (create, scan, open workbench, ask Zeus when reasoning is required).
4. Deterministic navigation and filters call the router directly — do not round-trip those through Ask Zeus.
5. Pin frequent pages to Favorites (`/favorites`).
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Customizable dashboard widget grid (VM count, capacity, health, events, favorites, alerts) with layo.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [Favorites](../core/favorites.md)
- [Home](../core/home.md)
- [System Health](../observe/system-health.md)
