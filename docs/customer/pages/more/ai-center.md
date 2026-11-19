# AI Center

## Purpose

AI-assisted SRE, migration, and security advisors grounded in cluster evidence (Forge / built-in LLM when configured).

## When to use it

- Ask for remediation suggestions with citations
- Draft manifests or runbooks with guardrails
- Pair with Incidents / Auto-Remediation for day-2 loops

## How to get there

- Route: `/ai-center`
- Related: `/forge`, `/nlp-command`, Settings → AI providers

## Operate from the console (UX)

1. Open `/ai-center` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the editorial hero and **Get the highlights**, then pick an advisor (SRE, migration, security, cost, capacity, network).
3. Use the center’s primary CTA (create, scan, open workbench, ask Zeus when reasoning is required).
4. Deterministic navigation and filters call the router directly — do not round-trip those through Ask Zeus.
5. Pin frequent pages to Favorites (`/favorites`).
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: AI-assisted SRE, migration, and security advisors grounded in cluster evidence (Forge / built-in LLM.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [Incidents](../observe/incidents.md)
- [Auto-Remediation](../../PAGE_INDEX.md) — `/auto-remediation`
- [Settings](../settings/settings.md)
