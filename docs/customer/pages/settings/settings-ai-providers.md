# Settings — AI providers

## Purpose

Register and manage the language-model providers that power Zeus OS AI features, plus routing rules, API keys, stored memory, and the prompt library.

## When to use it

- Point Zeus OS at Forge, a local Ollama endpoint, or another OpenAI-compatible provider
- Set which provider is the default and how requests are routed
- Review or clear stored AI memory before an audit
- Curate reusable prompts for your team

## How to get there

- Route: `/settings/ai-providers`
- Nav: **Settings → AI providers**
- Related: `/ai-center`, `/forge`, `/nlp-command`

## Operate from the console (UX)

1. Open `/settings/ai-providers` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Register and manage the language-model providers that power Zeus OS AI features, plus routing rules, API keys, stored me….
3. Change only the section you need (General / Appearance / Advanced / API access / …).
4. Save; API keys and SSO changes may require re-login.
5. Cluster-wide TLS/auth/data-dir remain server env — see Admin basics.
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Register and manage the language-model providers that power Zeus OS AI features, plus routing rules,.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [Settings overview](./settings.md)
- [AI Center](../more/ai-center.md)
- [Forge](../centers/forge.md)
- [Auto-Remediation](../more/auto-remediation.md)
