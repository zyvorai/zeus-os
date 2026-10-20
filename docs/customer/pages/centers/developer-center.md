# Developer Center

## Purpose

Operator and integrator hub for REST docs, API playground, CLI examples, webhooks, and plugin SDK entry points.

## When to use it

- Explore the live OpenAPI catalog
- Try endpoints in the API Playground
- Copy `zeus` CLI examples for VM and AI workflows
- Reach webhook tester or Plugins from one place

## How to get there

- Route: `/developer-center`
- Nav: **Admin → Developer Center**
- Related: `/api-docs`, `/api-playground`, `/terminal`, `/webhook-tester`, `/plugins`

## Operate from the console (UX)

1. Open `/developer-center` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Operator and integrator hub for REST docs, API playground, CLI examples, webhooks, and plugin SDK entry points.
3. Use the center’s primary CTA (create, scan, open workbench, ask Zeus when reasoning is required).
4. Deterministic navigation and filters call the router directly — do not round-trip those through Ask Zeus.
5. Pin frequent pages to Favorites (`/favorites`).
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Operator and integrator hub for REST docs, API playground, CLI examples, webhooks, and plugin SDK en.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [Plugins](./plugins.md)
- [Settings](../settings/settings.md)
- [API Playground](../more/api-playground.md)
