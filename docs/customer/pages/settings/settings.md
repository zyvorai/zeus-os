# Settings

## Purpose

Configure the Zeus OS experience and platform integrations: general, appearance, network, security, backup/DR, AI providers, API access, and advanced options.

## When to use it

- First login personalization (theme, sidebar)
- Admins enabling auth-related or backup integrations exposed in UI
- Creating API tokens for automation
- Pointing AI features at Forge / LLM providers

## How to get there

- Route: `/settings` (categories under `/settings/...`)
- Top bar quick link · rail pin

### Common categories

| Category | Typical path | Who |
|----------|--------------|-----|
| General | `/settings/general` | Everyone |
| Appearance | `/settings/appearance` | Everyone |
| Network | `/settings/network` | Admin |
| Security | `/settings/security` | Admin |
| Backup / DR | `/settings/backup-dr` | Admin |
| AI providers | `/settings/ai-providers` | Admin |
| API access | `/settings/api-access` | Admin / automation users |
| Advanced | `/settings/advanced` | Admin |

Exact category routes follow the Settings shell in your build.

## Operate from the console (UX)

1. Open `/settings` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Configure the Zeus OS experience and platform integrations: general, appearance, network, security, backup/DR, AI provid….
3. Change only the section you need (General / Appearance / Advanced / API access / …).
4. Save; API keys and SSO changes may require re-login.
5. Cluster-wide TLS/auth/data-dir remain server env — see Admin basics.
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Configure the Zeus OS experience and platform integrations: general, appearance, network, security, .
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [Using the Dashboard](../../using-the-dashboard.md)
- [API Docs](../../PAGE_INDEX.md) — `/api-docs`
- [Identity Center](../../PAGE_INDEX.md) — `/identity-center`
