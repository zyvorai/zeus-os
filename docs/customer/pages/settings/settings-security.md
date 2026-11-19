# Settings — Security

## Purpose

Security-related configuration surfaced in the UI: active product edition, identity and SSO panels, browser console access policy, and a link into the security overview.

## When to use it

- Confirm which edition and feature set is active
- Review or configure Active Directory / LDAP and SAML SSO integration
- Decide whether browser console access is permitted for operators
- Jump to the security posture overview during a review

## How to get there

- Route: `/settings/security`
- Nav: **Settings → Security**
- Related: `/security`, `/users`, `/identity-center`, `/auth-audit`

## Operate from the console (UX)

1. Open `/settings/security` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Security-related configuration surfaced in the UI: active product edition, identity and SSO panels, browser console acce….
3. Change only the section you need (General / Appearance / Advanced / API access / …).
4. Save; API keys and SSO changes may require re-login.
5. Cluster-wide TLS/auth/data-dir remain server env — see Admin basics.
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Security-related configuration surfaced in the UI: active product edition, identity and SSO panels, .
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [Settings overview](./settings.md)
- [Security](../security/security.md)
- [Users](../security/users.md)
- [Identity Center](../centers/identity-center.md)
- [Admin basics](../../admin-basics.md)
