# API Playground

## Purpose

In-browser HTTP client for Zeus OS REST endpoints: pick a method and path, send authenticated requests, and inspect status, headers, and body.

## When to use it

- Try an API before wiring an integration
- Reproduce a failing call with the same bearer token as the UI
- Replay a recent request from history
- Explore preset inventory and health paths quickly

## How to get there

- Route: `/api-playground`
- Nav: **More → Tools & settings → API Playground**
- Related: `/api-docs`, `/debug`

## Operate from the console (UX)

1. Open `/api-playground` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: In-browser HTTP client for Zeus OS REST endpoints: pick a method and path, send authenticated requests, and inspect stat….
3. Use the center’s primary CTA (create, scan, open workbench, ask Zeus when reasoning is required).
4. Deterministic navigation and filters call the router directly — do not round-trip those through Ask Zeus.
5. Pin frequent pages to Favorites (`/favorites`).
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: In-browser HTTP client for Zeus OS REST endpoints: pick a method and path, send authenticated reques.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [API Docs](./api-docs.md)
- [Debug](./debug.md)
- [Settings](../settings/settings.md)

