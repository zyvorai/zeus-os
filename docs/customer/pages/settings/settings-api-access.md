# Settings — API access

## Purpose

Everything needed to automate against Zeus OS: scoped API tokens, the OpenAPI specification, rate-limit behaviour, and the FinOps change audit.

## When to use it

- Issue a token for CI, Terraform, or a monitoring integration
- Look up the live OpenAPI spec before writing a client
- Understand why an automation is being rate limited
- Review audited FinOps changes

## How to get there

- Route: `/settings/api-access`
- Nav: **Settings → API access**
- Related: `/users`, `/api-docs`, `/api-playground`

## Operate from the console (UX)

1. Open `/settings/api-access` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Everything needed to automate against Zeus OS: scoped API tokens, the OpenAPI specification, rate-limit behaviour, and t….
3. Change only the section you need (General / Appearance / Advanced / API access / …).
4. Save; API keys and SSO changes may require re-login.
5. Cluster-wide TLS/auth/data-dir remain server env — see Admin basics.
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Everything needed to automate against Zeus OS: scoped API tokens, the OpenAPI specification, rate-li.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [Settings overview](./settings.md)
- [API Docs](../more/api-docs.md)
- [API Playground](../more/api-playground.md)
- [Users](../security/users.md)
- [Developer Center](../centers/developer-center.md)
