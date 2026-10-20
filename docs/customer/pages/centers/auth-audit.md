# Auth audit log

## Purpose

Login and security event table sourced from `auth-audit.jsonl` on the Zeus OS data volume (`ZEUS_OS_DATA_DIR`).

## When to use it

- Investigate failed or unexpected sign-ins
- Support access reviews called out from Identity Center
- Confirm auth events after enabling SSO or MFA
- Export context for a security incident

## How to get there

- Route: `/auth-audit`
- Nav: **Security → Audit Logs**
- Related: `/identity-center`, `/events?tab=audit`, `/settings/security`

## Operate from the console (UX)

1. Open `/auth-audit` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Login and security event table sourced from `auth-audit.jsonl` on the Zeus OS data volume (`ZEUS_OS_DATA_DIR`).
3. Filter findings / policies by severity or namespace.
4. Open a row for evidence and remediation; use change-approval gates when enabled.
5. Export or acknowledge as your role allows — do not mute crit without a live condition handled.
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Login and security event table sourced from `auth-audit.jsonl` on the Zeus OS data volume (`ZEUS_OS_.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [Identity Center](./identity-center.md)
- [Security](../security/security.md)
- [Settings](../settings/settings.md)
