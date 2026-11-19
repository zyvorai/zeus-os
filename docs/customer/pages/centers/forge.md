# Forge

## Purpose

Native AI module hub — prompt handoff from AI Center, links to AI providers and GPU passthrough. Dedicated agent builder is not shipped on this page yet.

## When to use it

- Land a prompt forwarded from AI Center (`?prompt=` / `?vm=`)
- Open AI provider configuration (OpenAI, Anthropic, Ollama, air-gap)
- Jump to GPU passthrough inventory
- Confirm where routing and models are configured today

## How to get there

- Route: `/forge`
- Nav: **AI → Forge (AI)** (workspace switcher AI tile also points here)
- Related: `/ai-center`, `/settings/ai-providers`, `/gpu`

## Operate from the console (UX)

1. Open `/forge` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the editorial intro (eyebrow **Intelligence**, title **Forge**), then use the prompt card (if forwarded from AI Center) and the links to AI providers / GPU.
3. Use the center’s primary CTA (create, scan, open workbench, ask Zeus when reasoning is required).
4. Deterministic navigation and filters call the router directly — do not round-trip those through Ask Zeus.
5. Pin frequent pages to Favorites (`/favorites`).
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Native AI module hub — prompt handoff from AI Center, links to AI providers and GPU passthrough. Ded.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [AI Center](../more/ai-center.md)
- [Settings](../settings/settings.md)
- [GPU](../cluster/gpu.md)
