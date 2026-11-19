# NLP Command

## Purpose

Natural-language bar for VM power and lifecycle intents — parse plain English into a confirmed action before execution (labs tier).

## When to use it

- Quick start/stop/restart without hunting inventory filters
- Bulk intents such as “stop all VMs in namespace prod”
- Reuse recent commands from history
- Pair with AI Center when you need longer advisory workflows

## How to get there

- Route: `/nlp-command`
- Nav: **More → Insights → NLP Command** (labs tier)
- Related: `/ai-center`, `/vms`

## Operate from the console (UX)

1. Open `/nlp-command` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Natural-language bar for VM power and lifecycle intents — parse plain English into a confirmed action before execution (….
3. Use the center’s primary CTA (create, scan, open workbench, ask Zeus when reasoning is required).
4. Deterministic navigation and filters call the router directly — do not round-trip those through Ask Zeus.
5. Pin frequent pages to Favorites (`/favorites`).
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Natural-language bar for VM power and lifecycle intents — parse plain English into a confirmed actio.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [AI Center](./ai-center.md)
- [VMs](../core/vms.md)
- [VMIs](../core/vmis.md)
