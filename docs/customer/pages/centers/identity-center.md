# Identity Center

## Purpose

Landing hub for authentication and access governance — links to SSO, LDAP, MFA, Users & RBAC, auth audit, and API tokens.

## When to use it

- Configure SSO / OIDC / SAML or LDAP
- Enforce MFA from Security settings
- Open Users & RBAC or API service accounts
- Review stale admin access via Auth Audit

## How to get there

- Route: `/identity-center`
- Nav: **Admin → Identity Center**
- Related: `/users`, `/auth-audit`, `/settings/security`, `/settings/api-access`

## Operate from the console (UX)

1. Open `/identity-center` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Landing hub for authentication and access governance — links to SSO, LDAP, MFA, Users & RBAC, auth audit, and API tokens.
3. Use the center’s primary CTA (create, scan, open workbench, ask Zeus when reasoning is required).
4. Deterministic navigation and filters call the router directly — do not round-trip those through Ask Zeus.
5. Pin frequent pages to Favorites (`/favorites`).
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Landing hub for authentication and access governance — links to SSO, LDAP, MFA, Users & RBAC, auth a.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [Auth audit log](./auth-audit.md)
- [Settings](../settings/settings.md)
- [Users & RBAC](../../PAGE_INDEX.md) — `/users`
