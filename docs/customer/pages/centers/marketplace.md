# Marketplace

## Purpose

Browse and deploy VM templates and blueprints — search, OS and category filters, favorites, AI draft assist, and a deploy wizard.

## When to use it

- Find a golden image or workload template to deploy
- Filter by OS family or marketplace category
- Deploy a template into a namespace via the wizard
- Generate a draft template from a natural-language prompt (when AI is configured)

## How to get there

- Route: `/marketplace`
- Nav: **Modules → Marketplace**
- Related: `/templates`, `/blueprints`, `/image-factory`, `/vms`

## Operate from the console (UX)

1. Open `/marketplace` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Browse and deploy VM templates and blueprints — search, OS and category filters, favorites, AI draft assist, and a deplo….
3. Use the center’s primary CTA (create, scan, open workbench, ask Zeus when reasoning is required).
4. Deterministic navigation and filters call the router directly — do not round-trip those through Ask Zeus.
5. Pin frequent pages to Favorites (`/favorites`).
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Browse and deploy VM templates and blueprints — search, OS and category filters, favorites, AI draft.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [Virtual Machines](../core/vms.md)
- [Templates](../cluster/templates.md)
- [Plugins](./plugins.md)
- [AI Center](../more/ai-center.md)
