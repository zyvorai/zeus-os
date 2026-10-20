# API Docs

## Purpose

Browsable REST reference for Zeus OS: live OpenAPI when available, plus categorized method/path descriptions for VMs, nodes, pods, and more.

## When to use it

- Discover endpoints before scripting or automation
- Confirm request/response shapes for an integration
- Search the catalog by path or description
- Jump from docs into hands-on calls in the playground

## How to get there

- Route: `/api-docs`
- Nav: **Top bar → API Docs** (also Support / quick links)
- Related: `/api-playground`, `/settings`, `/terminal`

## Operate from the console (UX)

1. Open `/api-docs` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Browsable REST reference for Zeus OS: live OpenAPI when available, plus categorized method/path descriptions for VMs, no….
3. Use the center’s primary CTA (create, scan, open workbench, ask Zeus when reasoning is required).
4. Deterministic navigation and filters call the router directly — do not round-trip those through Ask Zeus.
5. Pin frequent pages to Favorites (`/favorites`).
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Browsable REST reference for Zeus OS: live OpenAPI when available, plus categorized method/path desc.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [API Playground](./api-playground.md)
- [Settings](../settings/settings.md)
- [Terminal](./terminal.md)
